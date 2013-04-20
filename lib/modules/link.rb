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
      "!links XXX?                       =>"
      "!link [-add|-del] <id> <value>    => add/del the <value> association to the <id>",
      "!link_user [-add|-del] <username> => add/del a user who can add links"
    ]

    def initialize runner
      @links = Hash.new([])
      super runner
    end

    def load_mod
      @links.default = []
    end

    def startMod

    end


    class Options < ModulesOptions
      generate_to_catch :add_link      => /^!link\s*-add\s*\S*\s*\S*/,
                        :del_link      => /^!link\s*-del\s*\S*\s*\S*/,
                        :link          => /^!link\s*[^-\s]\S*\s/,
                        :add_user_link => /^!link_user\s*-add\s/,
                        :del_user_link => /^!link_user\s*-del\s/

      generate_value    :link          => /^!link\s*([^-\s?][^?\s]*)\??/,
                        :id            => /^!link\s*-\S*\s*([^-\s?][^?\s]*)\s/,
                        :value         => /^!link\s*-\S*\s*\S*\s*(\S*)/

      generate_who

    end
  end
end
