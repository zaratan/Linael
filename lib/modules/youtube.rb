# -*- encoding : utf-8 -*-

require('open-uri')
require('htmlentities')

module Linael
  class Modules::Youtube < ModuleIRC

    Name="youtube"
    Constructor="Vinz_"

    def startMod
      add_module :msg => [:youtube]
    end

    def youtube privMsg
      if (Options.link? privMsg.message and privMsg.who !="Internets")
        options = Options.new privMsg
        open("http://www.youtube.com/watch?v=#{options.id}").read =~ /<title>(.*?)<\/title>/
        answer(privMsg,HTMLEntities.new.decode("#{privMsg.who}: #{$1}"))
      end
    end

    def link? privMsg
      privMsg.message =~ /http:\/\/(?:www\.)?youtu.*?\/(\S+)/
      @id = $1.gsub("watch?v=", "")
    end

    class Options < ModulesOptions
      generate_to_catch :link => /http[s]?:\/\/(?:www\.)?youtu.*\?/

      generate_value :id => /http[s]?:\/\/(?:www\.)?youtu.*watch\?v=([^&]*)/

    end

  end
end
