actions :create
default_action :create

attribute :extension_name, :kind_of => String, :name_attribute => true
attribute :git_url, :kind_of => String
attribute :extensions_dir, :kind_of => [String, NilClass]
