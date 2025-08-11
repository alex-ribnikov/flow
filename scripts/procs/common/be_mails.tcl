####################################
# Users mail list
####################################
proc be_get_supper_user_email { {project "NONE"} } {

    set supper_user_mail_arr(idon)  "all"
    set supper_user_mail_arr(avnera)  "all"
    set supper_user_mail_arr(royl)  "nextcore"
    set supper_user_mail_arr(nitzano)  "nxt013"
    unset -nocomplain arr
    
    foreach key [array name supper_user_mail_arr] {
        set value $supper_user_mail_arr($key)
        if {[regexp all $value] || [regexp $project $value]} {
            lappend arr $key
        }
    }
    if {[info exists arr] && [llength $arr] > 0} {
        return $arr
    }
        
}

####################################
# Users mail list
####################################
proc be_get_user_email { {user ""} } {

    array set user_mail_arr "
    avnera      avner.adania@nextsilicon.com
    idon        ido.naishtein@nextsilicon.com
    ory         or.yagev@nextsilicon.com
    meravi      merav.ifrach@nextsilicon.com
    royl        roy.leibo@nextsilicon.com
    hilleln     hillel.nevo@nextsilicon.com
    yigal       yigal.hacham@nextsilicon.com
    igorb       igor.bernshtein@nextsilicon.com
    liorb       lior.burshtein@nextsilicon.com
    liorz       lior.zucker@nextsilicon.com
    nitzano     nitzan.ovadia@nextsilicon.com
    talm        tal.mazor@nextsilicon.com
    shaisa      shai.sade@nextsilicon.com
    moshela     moshe.lavi@nextsilicon.com
    rivkah      rivka.henchinski@nextsilicon.com
    tamarc      tamar.cooper@nextsilicon.com
    rinate      rinat.epstein@nextsilicon.com
    noac        noa.cohen@nextsilicon.com
    ehudk       ehud.kantorovich@nextsilicon.com
    bineett     bineet.thaker@nextsilicon.com
    elianaf     eliana.feifel@nextsilicon.com 
    einava      einav.aharon@nextsilicon.com
    prasanthm   prasanth.muggu@nextsilicon.com
    priyeshar   priyesha.ranjan@nextsilicon.com
    rajasa      raja.sreenivas.atmakuri@nextsilicon.com
    peruguumr   perugu.uma.maheswara.rao@nextsilicon.com
    vijayabharathia   vijayabharathi.ambalavanan@nextsilicon.com
    alexr       alex.ribnikov@nextsilicon.com
    ex-gilads   Gilad.Stossel@synopsys.com
    ex-eyal     Eyal.Gitter@synopsys.com
    "
    if { $user == "" } { set user $::env(USER) }
    
    if { [info exists user_mail_arr($user)] } {
          return $user_mail_arr($user)
    } else {        
        if { ![catch { set address [exec git config --global user.email] } res] && $address != "" } {
            return [regsub -all {\"} $address {}]
        }                 
        puts "-W- No email adress found for $user"
        return ""
    }    
}

