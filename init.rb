ActionDispatch::Callbacks.to_prepare do
  require 'orfilter_query_patch'
end

Redmine::Plugin.register :_query do
  name 'Using OR in query '
  author 'LTT Quan'
  description 'This plugin allows simple use of OR operator in query'
  version '0.0.1'
end

