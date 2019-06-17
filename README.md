# アプリケーションの作成

```sh
rails new . -T -O
echo "gem 'active_hash'" >> Gemfile
bundle
rails g scaffold prefecture name
vi app/model/prefecture.rb
```
```rb
class Prefecture < ActiveYaml::Base
  set_root_path 'master'
  set_filename 'prefectures'
end
```
```sh
vi master/prefectures.yml
```
```yaml
- id: 1
  name: 北海道
- id: 2
  name: 青森県

...

- id: 47
  name: 沖縄県
```
```sh
rails c
```
```rb
prefecture = Prefecture.first
#=> #<Prefecture:0x00007f8294dcf578 @attributes={:id=>1, :name=>"北海道"}>
prefecture.name
#=> "北海道"
prefecture.name = 'アイヌ'
#=> "アイヌ"
prefecture.save
#=> true
Prefecture.first.name
#=> "アイヌ"
Prefecture.new(id: 48, name: '幻県').save
#=> true
Prefecture.last.name
#=> "幻県"
```

# ActiveHashのデータについて
ActiveHashのデータは配列やYamlで記述できるがその方法は多岐にわたる
```rb
# fieldを定義し、それ以外のキーを持つ値を弾く。
# idは定義しなくてもOK
class Prefecture < ActiveHash::Base
  # デフォルト値を設定することもできる。
  field :name, default: 'Unknown'

  create name: '北海道'

  # idは自動でインクリメントされるが明示的に指定することもできる
  # ちなみに数値以外でもなんでも入ってしまう(String, Boolean, etc...)
  create id: 99, name: '青森県'

  # fieldで定義されてないキーを持つものはNoMethodErrorを吐く
  # create name: '岩手県', country: '日本'
  # NoMethodError (undefined method `country=' for #<Prefecture:0x00007f97da211208>)

  # createの代わりにaddも使える
  add()
end
```
```rb
Prefecture.all
#==> [#<Prefecture:0x00007f97d91dfa38 @attributes={:name=>"北海道", :id=>1}>, #<Prefecture:0x00007f97d91df240 @attributes={:id=>99, :name=>"青森県"}>, #<Prefecture:0x00007f97d91de4f8 @attributes={:id=>100}>]

# 一つ前のデータのIDの連番になる
Prefecture.last.id
#=> 100

# 値がnilの場合デフォルト値が設定されていればその値が返される
Prefecture.last.name
#=> "Unknown"

# fieldで定義されたもの以外のキーを含んだものはNoMethodErrorを吐く
Prefecture.new name: '青森県', country: '日本'
# NoMethodError (undefined method `country=' for #<Prefecture:0x00007f97da211208>)
```
```rb
class Prefecture < ActiveHash::Base
  # self.data = で書くとfieldを明示的に定義せずとも自動定義される
  # 明示的にfieldを指定することもできる
  # その場合、自動定義されるfieldはこれを上書きしない
  self.data = [
    # idは自動でインクリメントされるが明示的に指定することもできる
    { name: '北海道' },
    { name: '青森県', country: '日本' }
  ]
end
```
```rb
Prefecture.all
#=> => [#<Prefecture:0x00007f97dac87570 @attributes={:name=>"北海道", :id=>1}>, #<Prefecture:0x00007f97dac872c8 @attributes={:name=>"青森県", :country=>"日本", :id=>2}>]

# 自動でfieldが定義されているのでそれ以外のキーはNoMethodErrorを吐く
Prefecture.new name: '岩手県', area: '東北'
# NoMethodError (undefined method `area=' for #<Prefecture:0x00007f97da32df60>)
```

データの定義を外部に記述することができる  
大きく分けて2種類ある  
どれも全てfieldは自動定義される

1. config/initializers以下に書く
```rb
# app/model/prefecture.rb
class Prefecture < ActiveHash::Base; end

# config/initializers/data.rb
Rails.application.config.to_prepare do
  Prefecture.data = [
    { name: '北海道' },
    { name: '青森県' }
  ]
end
```

2. yamlで書く
```rb
# yamlで書く場合継承するクラスがActiveYaml::Baseに変わるので注意
class Prefecture < ActiveYaml::Base
  # リポジトリまでのpath
  set_root_path 'master'
  # ファイル名
  set_filename 'prefectures'
end
```
```yaml
# master/prefectures.yml
- name: 北海道
- name: 青森県
```
ちなみにArrayでなくHashで書くこともできる  
データに名前をつけていきたいときなどはこちらでもOK  
運用する際にこの名前は影響を与えない
```yaml
hokkaido:
  name: 北海道
aomoriken:
  name: 青森県
```
