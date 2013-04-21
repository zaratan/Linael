
def self.linael(name,config_hash)

  #create a class with the name
  #add config in it
  #change scope for class
    #add an Options class
    #yield in it with the check

end

module Linael

  class InterruptLinael < Interrupt
  end

  class ModuleIRC
    def self.on(type, name,regex,config_hash)
    
      #define a method with name,
      #                checking regex,
      #                config with hash
      #                giving a type_msg and options if PrivateMsg
      #                which do yield
      #                catch special exceptions

    end

    def self.value(hash)
      
      
    end

    def self.match(hash)
         
    end

    def before(&block)
      raise InterruptLinael, "not matching" unless block.call
    end
  end

end

#linael "youtube", constructor:"Vinz_" do
#
#  value :id => //
#
#  on :msg, :youtube, // do
#    
#    before do
#      msg.who != "Internets"
#    end
#
#    open("http://www.youtube.com/watch?v=#{options.id}").read =~ /<title>(.*?)<\/title>/
#    answer(privMsg,HTMLEntities.new.decode("#{privMsg.who}: #{$1}"))
#  end
#
#
#end
