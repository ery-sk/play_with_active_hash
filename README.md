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
大きく分けて4種類ある  
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

2. yamlファイルから読み込む
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

3. jsonファイルから読み込む
```rb
# JSONで書く場合継承するクラスがActiveJSON::Baseに変わるので注意
class Prefecture < ActiveJSON::Base
  # リポジトリまでのpath
  set_root_path 'master'
  # ファイル名
  set_filename 'prefectures'
end
```
```json
[
  {
    "name": "北海道"
  },
  {
    "name": "青森県"
  }
]
```
これもHashで書くこともできる
```json
{
  "hokkaido" :{
    "name": "北海道"
  },
  "aomoriken": {
    "name": "青森県"
  }
}
```

4. その他ファイルから読み込む
```rb
# yamlで書く場合継承するクラスがActiveFile::Baseに変わるので注意
class Prefecture < ActiveFile::Base
  # リポジトリまでのpath
  set_root_path 'master'
  # ファイル名
  set_filename 'prefectures'

  class << self
    def extension
      ".super_secret"
    end

    def load_file
      MyAwesomeDecoder.load_file(full_path)
    end
  end
end
```
ドキュメントにはこう書いてあるけどよくわからなかった

## データの操作

ActiveHashはActiveRecordの感覚でメソッドが使える  
具体的にクラスメソッドには以下がある
```rb
Prefecture.all
Prefecture.count
Prefecture.first
Prefecture.last
Prefecture.find 1
Prefecture.find [1,2]
Prefecture.find :all                   # Prefecture.allと一緒
Prefecture.find :all, args             # 2番目の引数は無視されるので現状↑と同じ
Prefecture.find_by_id 1
Prefecture.find_by name: '北海道'
Prefecture.find_by! name: 'マンハッタン' #=> ActiveHash::RecordNotFound
Prefecture.where name: '北海道'
Prefecture.find_all_by_name '北海道'    # where(name: '北海道') と同じ
Prefecture.where.not name: '北海道'
```
インスタンスメソッドは以下
```rb
Prefecture#id
Prefecture#id=
Prefecture#quoted_id     # IDをInteger型で返す
Prefecture#to_param      # IDをString型で返す
Prefecture#new_record?
Prefecture#readonly?     # trueが返ってくる
Prefecture#hash          # ハッシュ値が返ってくる
Prefecture#eql?          # 比較する、IDがnilなら必ずfalseになる
Prefecture#name?         # nameフィールドに値があるかどうか
```
値の上書きもできる
```rb
Prefecture.first.name = 'マンハッタン'
#=> "マンハッタン"
Prefecture.first.name
#=> "マンハッタン"
```
擬似的なレコードの保存もできる
```rb
prefecture = Prefecture.new(name: 'マンハッタン')
#=> true
prefecture.new_record?
#=> true
prefecture.save
prefecture.new_record?
#=> false
Prefecture.last
#=> #<Prefecture:0x00007f988a40c980 @attributes={:name=>"マンハッタン", :id=>48}>
```
保存方法にはいくつかの種類がある
```rb
Prefecture.insert( record ) # 戻り値が保存後のPrefecture.all
Prefecture.create
Prefecture.create!          # バリデーションなどはないので↑と一緒
Prefecture#save
Prefecture#save!            # バリデーションなどはないので↑と一緒
```
擬似的なレコードのクリア
```rb
Prefecture.delete_all
#=> []
Prefecture.all
#=> []
```

## 関連付け
ActiveHashはActiveRecordオブジェクトと関連づけることができる

### belongs_to
```rb
class User < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :prefecture
end
```
ActiveRecord::Baseを拡張して紐づける方法もある
```rb
ActiveRecord::Base.extend ActiveHash::Associations::ActiveRecordExtensions

class User < ActiveRecord::Base
  belongs_to_active_hash :prefecture
end
```
ショートカットを作成できる
```rb
class User < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :prefecture, shortcuts: [:name]
end
```
```rb
User.first.prefecture_name = '北海道'
# 以下と同じ
User.first.prefecture = Prefecture.find_by(name: '北海道')

User.first.prefecture_name
# 以下と同じ
User.first.prefecture.try(:name)

# 動きがわかりづらいので多分使わないと思う....
```

### hash_many
```rb
class Prefecture < ActiveHash::Base
  include ActiveHash::Associations
  has_many :users
end

class User < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :prefecture
end
```
大前提としてActiveHashオブジェクトがActiveRecordオブジェクトの子にはならない  
IDをハードコーディングする必要があり、それは依存関係の逆転である

## データの分割管理
複数のYamlやJSONファイルからデータを取り込むことができる  
ただしファイルの書き方をArrayかHashで統一しなければならない
```rb
class Country < ActiveYaml::Base
  use_multiple_files
  set_filenames "europe", "america", "asia", "africa"
end
```

## aliasesを使う
Yamlファイルにデータを書き込む時、aliasesを用意できる
```yaml
- /aliases:
  soda_flavor: &soda_flavor
    sweet
  soda_price: &soda_price
    1.0

- id: 1
  name:
  flavor: *soda_flavor
  price: *soda_price
```
```rb
class Soda < ActiveYaml::Base
  include ActiveYaml::Aliases
end

Soda.first.flavor
#=> sweet
Soda.first.price
#=> 1.0
```
マジックナンバーがごちゃごちゃしてるようなデータを作成するときに使えそう  
あまり多用するとかえってわかりにくくなりそう

## データのリロード

```rb
Prefecture.delete_all
#=> []
Prefecture.all
#=> []
Prefecture.reload true
Prefecture.all
#=> [#<Prefecture:0x00007f988a295e58 @attributes={:id=>1, :name=>"北海道"}>, ...]
```

## ENUM

指定したフィールドを定数扱いにし、アクセスできる
```rb
class Prefecture < ActiveHash::Base
  self.data = [
    { name: 'hokkaido' }
  ]
  include ActiveHash::Enum
  enum_accessor :name
end

Prefecture::HOKKAIDO
#=> #<Prefecture:0x00007f988a33f520 @attributes={:name=>"hokkaido", :id=>1}>
```
RailsのENUMとは違うし、日本語ダメだし、あまり使う機会もなさそう
