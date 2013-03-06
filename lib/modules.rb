# -*- encoding : utf-8 -*-
class ModuleIRC

  include Action

  def addKickMethod(instance,nom,ident)
    @runner.kickAct[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg)}
  end

  def delKickMethod(instance,ident)
    @runner.kickAct.delete(instance.class::Name+ident)
  end

  def addNickMethod(instance,nom,ident)
    @runner.nickAct[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg)}
  end

  def delNickMethod(instance,ident)
    @runner.nickAct.delete(instance.class::Name+ident)
  end

  def addJoinMethod(instance,nom,ident)
    @runner.joinAct[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg)}
  end

  def delJoinMethod(instance,ident)
    @runner.joinAct.delete(instance.class::Name+ident)
  end

  def addPartMethod(instance,nom,ident)
    @runner.partAct[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg)}
  end

  def delPartMethod(instance,ident)
    @runner.partAct.delete(instance.class::Name+ident)
  end

  def addMsgMethod(instance,nom,ident)
    @runner.msgAct[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg) if actAuthorized?(instance,msg)}
  end

  def delMsgMethod(instance,ident)
    @runner.msgAct.delete(instance.class::Name+ident)
  end

  def addModeMethod(instance,nom,ident)
    @runner.modeAct[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg)}
  end

  def delModeMethod(instance,ident)
    @runner.modeAct.delete(instance.class::Name+ident)
  end

  def addCmdMethod(instance,nom,ident)
    @runner.cmdAct[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg) if actAuthorized?(instance,msg)}
  end

  def delCmdMethod(instance,ident)
    @runner.cmdAct.delete(instance.class::Name+ident)
  end

  def addAuthMethod(instance,nom,ident)
    @runner.authMeth[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg)}
  end

  def delAuthMethod(instance,ident)
    @runner.authMeth.delete(instance.class::Name+ident)
  end

  def addNoticeMethod(instance,nom,ident)
    @runner.noticeAct[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg)}
  end

  def delNoticeMethod(instance,ident)
    @runner.noticeAct.delete(instance.class::Name+ident)
  end

  def addAuthCmdMethod(instance,nom,ident)
    @runner.cmdActAuth[instance.class::Name+ident] = Proc.new {|msg| instance.send(nom,msg) if actAuthorized?(instance,msg)}
  end

  def delAuthCmdMethod(instance,ident)
    @runner.cmdActAuth.delete(instance.class::Name+ident)
  end

  def actAuthorized?(instance,msg)
    true
  end

  def getModule(name)
    @runner.modules.detect {|mod| mod.class == Modules::Module}.modules[name]
  end

  def self.requireAuth?
    false
  end

  def self.auth?
    false
  end

  def self.requiredMod
    []
  end

  Name=""

  Help=[]

  Constructor="Zaratan"

  def startMod()

  end


  def endMod()

  end	

  def help()
    ""
  end

  def initialize(runner)
    @runner=runner
    @irc=runner.irc
  end


  attr_reader :runner

end

module Modules
end
