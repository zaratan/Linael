require_relative '../../lib/core/core.rb'

describe Linael::Core do

  describe "::start_linael" do
  
    before(:each) do
      Linael::Core::SocketList = double("sockets")
      allow(Linael::Core::SocketList).to receive(:new) {:owi}
      allow(Linael::Core).to receive(:main_loop) {true}
      Linael::Core.start_linael
    end

    it "initialize handlers" do
      Linael::Core.instance_variable_get(:@handlers).should be_an_instance_of Hash
    end

    it "initialize sockets" do
      Linael::Core.instance_variable_get(:@sockets).should be :owi
    end

    it "yield block" do
      allow(Linael::Core).to receive(:yield) {true}
      Linael::Core.start_linael { Linael::Core.instance_variable_set(:@test,:test)}
      Linael::Core.instance_variable_get(:@test).should be :test
    end

    it "launch the main loop" do
      expect(Linael::Core).to have_received(:main_loop).at_least(:once)
    end

  end

  describe "::send_message" do
    it "post a message to sockets" do
      @test = double("socks")
      allow(@test).to receive(:send_message) {true}

      Linael::Core::SocketList = double("sockets")
      allow(Linael::Core::SocketList).to receive(:new) {@test}
      allow(Linael::Core).to receive(:main_loop) {true}

      Linael::Core.start_linael 
      Linael::Core.send_message :owi

      expect(@test).to have_received(:send_message).with(:owi)
    end
  end

  describe "::start_server" do

    before(:each) do
      @socket = double("socks")
      allow(@socket).to receive(:send_message) {true}
      allow(@socket).to receive(:add) {true}

      @handler = double("handler")
      allow(@handler).to receive(:configure) {:configure}
      allow(@handler).to receive(:instance) {@handler}

      String.any_instance.stub(constantize: @handler)

      Linael::Core::SocketList = double("sockets")
      allow(Linael::Core::SocketList).to receive(:new) {@socket}
      allow(Linael::Core).to receive(:main_loop) {true}

      Linael::Core.start_linael 
    end
    
    it "initialize a new socket of the givent type" do
      Linael::Core.start_server :type,:options
      expect(@socket).to have_received(:add).at_least(:once).with(@handler,:options)
    end

    it "add a handler for the type" do
      Linael::Core.start_server :type,:options
      Linael::Core.instance_variable_get(:@handlers)[:type].should be @handler
    end

    it "configure the handler" do
      Linael::Core.start_server(:type,:options).should be :configure
      
    end

    it "do not add nor configure a handler twice" do
      Linael::Core.start_server(:type,:options).should be :configure
      Linael::Core.start_server(:type,:options).should_not be :configure
    end

  end

  describe "::main_loop" do
    
    before(:each) do
      @socket = double("socks")
      allow(@socket).to receive(:send_message) {true}
      allow(@socket).to receive(:add) {true}
      allow(@socket).to receive(:gets).and_return(Struct.new(:type,:element).new(:type,:element),nil)

      @handler = double("handler")
      allow(@handler).to receive(:configure) {:configure}
      allow(@handler).to receive(:handle) {:handle}
      allow(@handler).to receive(:instance) {@handler}
      allow(@handler).to receive(:[]) {@handler}

      String.any_instance.stub(constantize: @handler)

      Linael::Core::SocketList = double("sockets")
      allow(Linael::Core::SocketList).to receive(:new) {@socket}
      
      allow(Linael::Core).to receive(:sleep) {:sleep}

      Linael::Core.instance_variable_set(:@sockets,@socket)
      Linael::Core.instance_variable_set(:@handlers,@handler)
    end
    
    it "take message from sockets" do
      Linael::Core.main_loop
      expect(@socket).to have_received(:gets).twice
    end


    it "only send messages that should and can be handled" do
      allow(@socket).to receive(:gets).and_return(nil)
      Linael::Core.main_loop 
      
      allow(@handler).to receive(:[]) {false}
      allow(@socket).to receive(:gets).and_return(Struct.new(:type,:element).new(:type,:element),nil)
      Linael::Core.main_loop 
      
      expect(@handler).to_not have_received(:handle)
    end 

    it "send message to the right handler" do
      Linael::Core.main_loop
      expect(@handler).to have_received(:[]).at_least(:once).with(:type)
    end


       assert :hash do
             x = nil
              
                 x.is_a?(Hash)
                   end
        
         assert :array do
               x = nil
                
                   x.is_a?(Array)
                     end
          
           assert :is_a_fixnum do
                 x = nil
                  
                     x.is_a?(Integer)
                       end
            
             assert :is_a_fixnum do
                   x = nil
                    
                       x.is_a?(Fixnum)
                         end
              
               assert :is_a_numeric do
                     x = nil
                      
                         x.is_a?(Numeric)
                           end
                
                 assert :is_a_string do
                       x = nil
                        
                           x.is_a?(String)
                             end
                  
                   assert :is_a_symbol do
                         x = nil
                          
                             x.is_a?(Symbol)
                               end
                    
                     assert :is_a_class do
                           x = nil
                            
                               x.is_a?(Class)
                                 end
                      
                       assert :is_a_module do
                             x = nil
                              
                                 x.is_a?(Module)
                                   end
                        
                         assert :global_variable do
                            
                               defined?($x) == 'global-variable'
                                 end
                          
                           assert :local_variable do
                              
                                 defined?(x) == 'local-variable'
                                   end
                            
                             assert :instance_variable do
                                
                                   defined?(@x) == 'instance-variable'
                                     end
                              
                               assert :constant do
                                  
                                     defined?(X) == 'constant'
                                       end


  end

end
