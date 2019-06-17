# frozen_string_literal: true

# class Prefecture < ActiveYaml::Base
#   set_root_path 'master'
#   set_filename 'prefectures'
# end

class Prefecture < ActiveHash::Base; end
#   field :name, default: 'Unknown'
#   create name: '北海道'
#   create()
# end

# class Prefecture < ActiveHash::Base
#   self.data = [
#     { name: '北海道' },
#     { name: '青森県', country: '日本' }
#   ]
# end
