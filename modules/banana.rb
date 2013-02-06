#encoding: utf-8

class Modules::Banana < ModuleIRC

Name="banana"

Lyrics=[
"http://www.youtube.com/watch?v=vNie6hVM8ZI",
" ",
"ba-ba-ba-ba-ba-nana (2x)",
" ",
	"banana-ah-ah (ba-ba-ba-ba-ba-nana)",
	"potato-na-ah-ah (ba-ba-ba-ba-ba-nana)",
	"banana-ah-ah (ba-ba-ba-ba-ba-nana)",
	"togari noh pocato-li kani malo mani kano",
	"chi ka-baba, ba-ba-nana",
" ",
	"yoh plano boo la planonoh too",
	"ma bana-na la-ka moobi talamoo",
	"ba-na-na",
" ",
	"ba-ba (ba-ba-ba-ba-banana)",
	"PO-TAE-TOH-OH-OH (ba-ba-ba-ba-banana)",
	"togari noh pocato li kani malo mani kano",
	"chi ka-ba-ba, ba-ba-naNAAAHHHH!!!!"
]

User=[
	"nayo",
	"zaratan",
	"lilin",
	"grunthi",
	"alya",
	"zag",
	"sayaelis",
	"tantraa"
]

def startMod
	addCmdMethod(self,:song,":song")
end

def endMod
	delCmdMethod(self,":song")
end


def song privMsg
	if (module? privMsg)
		Lyrics.each{|line| answer(privMsg,line);sleep(0.5)}
	end
end


def module? privMsg
	(privMsg.message.encode.downcase =~ /^!banana/) && ((privMsg.who.downcase =~ /nayo|zaratan|lilin|grunthi|alya|zag|sayaelis|unau|tantraa/) || (privMsg.private_message?))
end

end
