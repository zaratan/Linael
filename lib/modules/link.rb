# -*- encoding : utf-8 -*-

module Linael
  class Modules::Link < ModuleIRC

    Name="link"

    Help=[
      "Module : Link",
      " ",
      "A module for associate things like \"ruby\" => [\"it's so great\",\"much better than perl\"]",
      " ",
      "=====Functions=====",
      "!link XXX?                        => answer a random thing for its assoc table",
      "!links XXX?                       =>",
      "!link [-add|-del] <id> <value>    => add/del the <value> association to the <id>",
      "!link_user [-add|-del] <username> => add/del a user who can add links"
    ]

    def initialize runner
      @links = Hash.new([])
      @users = []
      super runner
    end

    def load_mod
      @links.default = []
    end

    def self.require_auth
      true
    end

    def startMod
      add_module :cmd     => [:link,:add_link,:del_link,:links],
                 :cmdAuth => [:add_user_link,:del_user_link]
    end

    def add_link priv_msg
      if Options.add_link? priv_msg.message and @users.include?(priv_msg.who.downcase)
        options = Options.new priv_msg
        @links[options.id.downcase] = @links[options.id.downcase] << options.value
        answer(priv_msg,"#{options.id} is now : #{options.value}")
      end
    end

    def del_link priv_msg
      if Options.del_link? priv_msg.message and @users.include?(priv_msg.who.downcase)
        options = Options.new priv_msg
        @links[options.id.downcase].delete_at(options.value.to_i - 1)
        answer(priv_msg,"deleting entry number #{options.value} of #{options.id}")
      end
    end

    def link priv_msg
      if Options.link? priv_msg.message
        options = Options.new priv_msg
        links = @links[options.link]
        if links.empty?
          answer(priv_msg,"#{priv_msg.who}: I'm sorry, I really don't know :(")
        else
          answer(priv_msg,"#{priv_msg.who}: #{links[Random.rand(links.size)]}")
        end
      end
    end

    def links priv_msg
      if Options.links? priv_msg.message
        options = Options.new priv_msg
        links = @links[options.link]
        if links.empty?
          answer(priv_msg,"#{priv_msg.who}: I'm sorry, I really don't know :(")
        else
          to_print=[]
          links.each_with_index {|val,i| to_print << "##{i + 1}: #{val}"}
          talk(priv_msg.who,"#{to_print.join(",")}")
        end
      end
    end

    def add_user_link priv_msg
      if Options.add_user_link? priv_msg.message
        options = Options.new priv_msg
        @users << options.who.downcase unless @users.include? options.who.downcase
        answer(priv_msg,"Oki doki! #{options.who.downcase.capitalize} can now link :)")
      end
    end

    def del_user_link priv_msg
      if Options.del_user_link? priv_msg.message
        options = Options.new priv_msg
        @users.delete options.who.downcase
        answer(priv_msg,"Oki doki! #{options.who.downcase.capitalize} will no longer link anything")
      end
    end


    class Options < ModulesOptions
      generate_to_catch :add_link      => /^!link\s+-add\s+\S+\s+\S+/,
                        :del_link      => /^!link\s+-del\s+\S+\s+\S+/,
                        :link          => /^!link\s+[^-\s]\S*\s/,
                        :links         => /^!links\s+\S+/,
                        :add_user_link => /^!link_user\s+-add\s/,
                        :del_user_link => /^!link_user\s+-del\s/

      generate_value    :link          => /^!link[s]?\s+([^-\s?][^?\s]*)\??/,
                        :id            => /^!link\s+-\S*\s+([^-\s?][^?\s]*)\s/,
                        :value         => /^!link\s+-\S*\s+\S*\s+([^\n\r]+)/

      generate_who

    end
  end
end
