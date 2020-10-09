# -*- coding: utf-8 -*-
import sys
from email.mime.text import MIMEText
from email.utils import COMMASPACE, parseaddr
import smtplib

FROM_ADDR = "noreply+nvdaL10n@nvaccess.org"
FROM_DISPLAY = "NVDA localisation <%s>" % FROM_ADDR

addresses = {
    'default': {
        'lang': '',
        'email': ['nvdal10n@exbi.nvaccess.org'],
    },
    'af_ZA': {
        'lang':'Afrikaans',
        'email': ['Hendrik Steyn <groothendrik.steyn@gmail.com>'],
    },
    'am': {
        'lang':'Amharic',
        'email': ['KETEMA ZEREGAW <kzeregaw@msn.com>', 'Dr. Tamru E. Belay <g.braille@sympatico.ca>'],
    },
    'an': {
        'lang':'Aragonese',
        'email': ['Jorge Perez <jorgtum@gmail.com>', 'Jose M. Delicado <jm.delicado@nvda.es>'],
    },
    'ar': {
        'lang':'Arabic',
        'email': ['Fatma Mehanna <fatma.mehanna@gmail.com>', 'Shaimaa Ibrahim <shamse1@gmail.com>', 'Abdelkrim Bensaid <abdelkrim.bensaid@free.fr>', 'Omar Alojaimi <amrahmad1995@gmail.com>'],
    },
    'bg': {
        'lang':'Bulgarian',
        'email': ['Zahari Yurukov <zahari.yurukov@gmail.com>', 'Kostadin Kolev <k_kolev1985@mail.bg>'],
    },
    'ca': {
        'lang': 'Catalan',
        'email': ['Ruben Alcaraz <ruben.hangar1.8@gmail.com>', 'Dr. Mireia Ribera <mireia.ribera@gmail.com>', 'Santi Moese <santispock@gmail.com>', 'Marina Salse Rovira <salse@ub.edu>', 'Jose M. Delicado <jm.delicado@nvda.es>'],
    },
    'ckb': {
        'lang':'Central Kurdish',
        'email': ['Ali Ustek <aliustek@gmail.com>', 'Patrick Galasso <Patrice.galasso@gmail.com>', 'Jwanro Mustafa <jwanroabdula@hotmail.com>', 'Kosrat D Ahmad <kosrat.d.ahmad@gmail.com>', 'silva.hm88@gmail.com'],
    },
    'cs': {
        'lang': 'Czech',
        'email': ['Martina Letochova <letochova@seznam.cz>'],
    },
    'da': {
        'lang': 'Danish',
        'email': ['Daniel K. Gartmann <kontakt@nvda.dk>', 'Nicolai Svendsen <chojiro1990@gmail.com>', 'bue@vester-andersen.dk'],
    },
    'de': {
        'lang':'German',
        'email': ['Bernd Dorer <bdorer@mailbox.org>', 'David Parduhn <xkill85@gmx.net>', 'Rene Linke <rene.linke@hamburg.de>', 'Adriani Botez <adriani.botez@gmail.com>', 'Karl Eick <hozosch@web.de>', 'Robert Hänggi <aarjay.robert@gmail.com>', 'Astrid Waldschmetterling <a.r.waldschmetterling@gmx.de>'],
    },
    'de_CH': {
        'lang':'Swiss German',
        'email': ['Robert Hänggi <aarjay.robert@gmail.com>'],
    },
    'el': {
        'lang': 'Greek',
        'email': ['Irene Nakas <irnakas@gmail.com>', 'Nikos Demetriou <nikosdemetriou@googlemail.com>', 'access@e-rhetor.com'],
    },
    'es': {
        'lang': 'Spanish',
        'email': ['Juan C. buno <oprisniki@gmail.com>', 'Noelia Martinez <nrm1977@gmail.com>', 'Remy Ruiz <remyruiz@gmail.com>', 'Jose M. Delicado <jm.delicado@nvda.es>'],
    },
    'es_CO': {
        'lang': 'Spanish Colombia',
        'email': ['Jorge Zarache <reydelasmaquinas@outlook.com>', 'Luis Carlos Gonzáles Moráles <luiscarlosgm@hotmail.es>', 'Jose M. Delicado <jm.delicado@nvda.es>'],
    },
    'fa': {
        'lang':'Farsi',
        'email': ['Ali Aslani <aslani.ali@gmail.com>', 'Mohammadreza Rashad <mohammadreza5712@gmail.com>'],
    },
    'fi': {
        'lang':'Finnish',
        'email': ['Jani Kinnunen <jani.kinnunen@wippies.fi>', 'Isak Sand <isak.sand@gmail.com>'],
    },
    'fr': {
        'lang':'French',
        'email': ['Michel such <michel.such@free.fr>', 'Patrick ZAJDA <patrick@zajda.fr>', 'Remy Ruiz <remyruiz@gmail.com>', 'Abdelkrim Bensaid <abdelkrim.bensaid@free.fr>', 'Cyrille Bougot <cyrille.bougot2@laposte.net>', 'Corentin Bacqu&-Cazenave <corentin@progaccess.net>'],
    },
    'ga': {
        'lang': 'Gaeilge',
        'email': ['Cearbhall OMeadhra <cearbhall.omeadhra@blbc.ie>', 'Ronan McGuirk <ronan.p.mcguirk@gmail.com>', 'Kevin Scannell <kscanne@gmail.com>'],
    },
    'gl': {
        'lang': 'Galician',
        'email': ['Juan C. buno <oprisniki@gmail.com>', 'Ivan Novegil <ivan.novegil@nvda.es>', 'Javier Curras <javier.curras@nvda.es>', 'Jose M. Delicado <jm.delicado@nvda.es>'],
    },
    'he': {
        'lang': 'Hebrew',
        'email': ['Shmuel Naaman <shmuel_naaman@yahoo.com>', 'Afik Sofir <afik.sofer@gmail.com>'],
    },
    'hi': {
        'lang': 'Hindi',
        'email': ['dipendra.lists@gmail.com', 'Doc Mehta <joyofinspiring@gmail.com>'],
    },
    'hr': {
        'lang': 'Croatian',
        'email': ['Hrvoje Katic <hrvojekatic@gmail.com>', 'Zvonimir Stanecic <9a5dsz@gozaltech.org>', 'Milo Ivir <mivir@milotype.de>', 'Dejana Rakic <dejana.rakic.2@gmail.com>'],
    },
    'hu': {
        'lang': 'Hungarian',
        'email': ['Aron OcsvAri <oaron@nvda.hu>'],
    },
    'is': {
        'lang':'Icelandic',
        'email': ['Birkir R. Gunnarsson <birkir.gunnarsson@gmail.com>', 'Hlynur Hreinsson <hm.hreinsson@gmail.com>'],
    },
    'it': {
        'lang':'Italian',
        'email': ['Simone Dal Maso <simone.dalmaso@gmail.com>', 'Alberto Buffolino <a.buffolino@gmail.com>'],
    },
    'ja': {
        'lang':'Japanese',
        'email': ['Takuya Nishimoto <nishimotz@gmail.com>', 'Minako Nonogaki <minakonono3519@gmail.com>'],
    },
    'ka': {
        'lang': 'Georgian',
        'email': ['Beqa Gozalishvili <beqaprogger@gmail.com>', 'Goderdzi Gogoladze <goderdzigogoladze@gmail.com>'],
    },
    'kk': {
        'lang': 'Kazakh',
        'email': ['Timati <timati_99999@mail.ru>'],
    },
    'kmr': {
        'lang': 'Northern Kurdish',
        'email': ['Imam Kahraman <imam.kahraman@googlemail.com>'],
    },
    'kn': {
        'lang':'Kannada',
        'email': ['Siddalingeshwar Ingalagi <ingalagisiddu@gmail.com>'],
    },
    'ko': {
        'lang':'Korean',
        'email': ['Joseph Lee <joseph.lee22590@gmail.com>', 'Chang-Hwan Jang <462356@gmail.com>', 'Dong Hee Park <hi@aheu.org>', 'Stanley Chung <stanley@mail.com>'],
    },
    'ky': {
        'lang':'Kyrgiz',
        'email': ['Bermet Zhakypbekova <bermet.zhakypbekova@gmail.com>'],
    },
    'lt': {
        'lang':'Lithuanian',
        'email': ['Paulius Leveris <paulius.leveris@gmail.com>', 'Rimas Kudelis <rq@akl.lt>'],
    },
    'lv': {
        'lang':'Latvian',
        'email': ['Verners Šteinbergs <verners_lnb@inbox.lv>'],
    },
    'mk': {
        'lang':'Macedonian',
        'email': ['zvonimir stanecic <9a5dsz@gozaltech.org>', 'Kiko Lazarev <kristijan.lazarev@gmail.com>'],
    },
    'mn': {
        'lang':'Mongolian',
        'email': ['Mongol NVDA-Translation <mongoliannvdatranslation@gmail.com>'],
    },
    'my': {
        'lang':'Burmese',
        'email': ['Benedict La hkun <lkbenedict@gmail.com>'],
    },
    'nb_NO': {
        'lang':'Norwegian bokmal',
        'email': ['David Hole <balubathebrave@gmail.com>', 'Bjornar Seppola <bjornar@seppola.net>'],
    },
    'ne': {
        'lang':'Nepali',
        'email': ['Puskal Gautam <nvda.nepali@gmail.com>'],
    },
    'nl': {
        'lang':'Dutch',
        'email': ['Bram Duvigneau <bram@bramd.nl>', 'Bart Simons <bart@bartsimons.be>', 'A Campen <a.campen@wxs.nl>', 'Leonard de Ruijter <alderuijter@gmail.com>'],
    },
    'pa': {
        'lang':'Punjabi',
        'email': ['Maheshinder Singh Khosla <mahesh.khosla@gmail.com>', 'Dinesh Mittal <punjabimaster259@gmail.com>'],
    },
    'pl': {
        'lang':'Polish',
        'email': ['Grzegorz Zlotowicz <grzezlo@wp.pl>', 'Patryk Faliszewski <patric3031@wp.pl>', 'Zvonimir Stanecic <9a5dsz@gozaltech.org>', 'Dorota Krac <dorkakrac@yandex.com>', 'Piotr Rakowski <kontakt@piotrrakowski.net>', 'Hubert Meyer <hubmeyer1989@gmail.com>', 'Arkadiusz Swietnicki <nuno69a@gmail.com>'],
    },
    'pt_BR': {
        'lang': 'Brazilian Portuguese',
        'email': ['Cleverson Casarin Uliana <clul@mm.st>', 'Marlin Rodrigues <marlincgrodrigues@yahoo.com.br>', 'Tiago Melo Casal <tcasal@intervox.nce.ufrj.br>'],
    },
    'pt_PT': {
        'lang': 'Portuguese',
        'email': ['Diogo Costa <diogojoca@gmail.com>', 'Rui Batista <ruiandrebatista@gmail.com>', 'Rui Fontes <rui.fontes@tiflotecnia.com>', 'Ângelo Abrantes <ampa4374@gmail.com>'],
    },
    'ro': {
        'lang': 'Romanian',
        'email': ['Dan Pungă <dan.punga@gmail.com>', 'Florian Ionașcu <7ro2014@gmail.com>', 'Alexandru Matei <alexandrumateistelian@gmail.com>', 'Nicuşor Untilă <nicusoruntila@yahoo.com>', 'Adriani Ionuț Botez <ionutz_tero@yahoo.com>', 'Dragoș Grecianu <grecianu.dragos@gmail.com>', 'Daniela Popovici <vlajna95@gmail.com>', 'George Antonio Andrei <george.andrei2002@gmail.com>'],
    },
    'ru': {
        'lang': 'Russian',
        'email': ['Zvonimir Stanecic <9a5dsz@gozaltech.org>', "Aleksandr Lin'kov <kvark128@yandex.ru>"],
    },
    'sk': {
        'lang':'Slovak',
        'email': ['Ondrej Rosik <ondrej.rosik@gmail.com>', 'Peter Vagner <peter.v@datagate.sk>', 'Jan Kulik <jan.kulik.szsle@outlook.sk>'],
    },
    'sl': {
        'lang':'Slovenian',
        'email': ['Jozko Gregorc <jozko.gregorc@gmail.com>'],
    },
    'so': {
        'lang':'Somali',
        'email': ['Othmanothman <othman82@hotmail.com>'],
    },
    'sr': {
        'lang':'Serbian',
        'email': ['Nikola Jovic <wwenikola123@gmail.com>', 'Janko Valencik <janko.valencik@alfanum.co.rs>', 'Zvonimir <9a5dsz@gozaltech.org>', 'Danijela Popovic <vlajna95@gmail.com>'],
    },
    'sv': {
        'lang':'Swedish',
        'email': ['Daniel Johansson <daniel.johansson@coeptus.se>', 'Niklas Johansson <sleeping.pillow@gmail.com>', 'Karl-Otto Rosenqvist <Karl-otto@mawingu.se>',],
    },
    'ta': {
        'lang':'Tamil',
        'email': ['Dinakar T.D. <td.dinkar@gmail.com>'],
    },
    'th': {
        'lang':'Thai',
        'email': ['Eakachai Charoenchaimonkon <eakachai@gmail.com>'],
    },
    'tr': {
        'lang':'Turkish',
        'email': ['Cagri Dogan <cagrid@hotmail.com>'],
    },
    'uk': {
        'lang':'Ukrainian',
        'email': ['Volodymyr Pyrig <vp88.mobile@gmail.com>'],
    },
    'ur': {
        'lang':'Urdu',
        'email': ['Waqas Ramzan <waqas.techlover@gmail.com>'],
    },
    'vi': {
        'lang':'Vietnamese',
        'email': ['Dang Hoai Phuc <danghoaiphuc@gmail.com>, Nguyen Van Dung <dungnv1984@gmail.com>'],
    },
    'zh_CN': {
        'lang':'Simplified Chinese',
        'email': ['vgjh2005@gmail.com', 'jiangtiandao901647@gmail.com', 'manchen0528@gmail.com', 'sysking1024@gmail.com', 'dingpengyu06@gmail.com', 'singer.mike.zhao@gmail.com'],
    },
    'zh_HK': {
        'lang': 'Traditional Chinese Hong Kong',
        'email': ['Eric Yip <ericycy@gmail.com>'],
    },
    'zh_TW': {
        'lang': 'Traditional Chinese Taiwan',
        'email': ['wangjanli@gmail.com', 'maro.zhang@gmail.com', 'Aaron Wu <waaron2000@gmail.com>', 'Victor Cai <surfer0627@gmail.com>'],
    },
}


def email(rcpts, subject, body, includeAdmin=False):
    if includeAdmin:
        rcpts.extend(addresses['default']['email'])
    if not rcpts:
        return
    msg = MIMEText(body, _charset="utf8")
    msg["From"] = FROM_DISPLAY
    msg["To"] = COMMASPACE.join(rcpts)
    msg["Subject"] = subject
    smtp = smtplib.SMTP("localhost")
    smtp.sendmail(FROM_ADDR,
        [parseaddr(rcpt)[1] for rcpt in rcpts],
        msg.as_string())

if __name__ == "__main__" and len(sys.argv) >= 2:
    lang = sys.argv[1]
    if not addresses.has_key(lang):
        print "unable to find language: %s" %lang
        sys.exit()
    # we were called from the webhook with lang, subject, body, so send email.
    if len(sys.argv) == 4:
        email(addresses[lang]['email'], sys.argv[2], sys.argv[3])
    # we were called by another script, with a lang code, spit out email addresses suitable for a commit message.
    elif len(sys.argv) == 2:
        print "\n".join(addresses[lang]['email'])
    else:
        print "dont know what to do."
