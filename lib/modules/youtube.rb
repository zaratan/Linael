# -*- encoding : utf-8 -*-

require('open-uri')
require('htmlentities')

module Linael
  class Modules::Youtube < ModuleIRC

    Name="youtube"

    def startMod
      add_module :msg => [:youtube]
    end

    def youtube privMsg
      if (link? privMsg)
        open("http://www.youtube.com/watch?v=#{@id}").read =~ /<title>(.*?)<\/title>/
        answer(privMsg,HTMLEntities.new.decode("#{privMsg.who}: #{$1}"))
      end
    end

    def link? privMsg
      privMsg.message =~ /http:\/\/(?:www\.)?youtu.*?\/(\S+)/
      @id = $1.gsub("watch?v=", "")
    end

  end
end