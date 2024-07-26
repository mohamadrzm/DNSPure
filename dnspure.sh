#!/bin/bash
if [ "$1" = "menu" ]; then 
    if [ ! -f /bin/dialog ]; then 
        apt update
        apt install dialog 
    fi

    if [ ! -f /etc/dialogrc ]; then
        echo "aspect = 0\ntab_len = 0\nvisit_items = OFF\nuse_shadow = ON\nuse_colors = ON\nscreen_color = (WHITE,RED,OFF)\nitem_selected_color = (WHITE,RED,OFF)\ntag_key_color = (RED,WHITE,OFF)\ntag_key_selected_color = (RED,WHITE,ON)\nbutton_active_color = (RED,WHITE,ON)\nbutton_inactive_color = (RED,WHITE,OFF)\nbutton_key_active_color = (GREEN,WHITE,OFF)\nbutton_key_inactive_color = (GREEN,WHITE,OFF)\nbutton_label_active_color = (RED,WHITE,ON)\nbutton_label_inactive_color = (RED,WHITE,OFF)" > "/etc/dialogrc"
    else 
        cp /etc/dialogrc /etc/dialogrc.bak
    fi
    

    HEIGHT=15
    WIDTH=50
    CHOICE_HEIGHT=6
    VERSION="1.5"


        DNS=$(nslookup google.com | grep Server)
        CHOICE_Provider=$(dialog --clear \
                        --backtitle "DNSPure Ver ${VERSION} - Your very little friend :)" \
                        --menu "Choose one of the DNS Providers:\ncurrent your DNS ${DNS}" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT \
                        1 "403" 2 "CLOUDFLARE" 3 "ELECTRO"  4 "SHECAN" 5 "GOOGLE" 6 "HELP" \
                        2>&1 >/dev/tty)

        clear
        case $CHOICE_Provider in
                1)
                    dns_provider="403"
                    ;;
                2)
                    dns_provider="CLOUDFLARE" 
                    ;;
                3)
                    dns_provider="ELECTRO" 
                    ;;
                4)
                    dns_provider="SHECAN" 
                    ;;
                5)
                    dns_provider="GOOGLE"
                    ;;
                6) 
                    dialog --backtitle "DNSPure Ver ${VERSION} - Explanations to choose better :)" --msgbox " 403 - For Developers \n\n CLOUDFLARE - For Gamers and Normal Users \n\n ELECTRO - For gamers and Web \n\n SHECAN - For web \n\n Google - For Web" 15 60
                    exit
                    ;;
                *)
                    exit
                    ;;
        esac
        CHOICE_MODE=$(dialog --clear \
                        --backtitle "DNSPure Ver ${VERSION} - Permanent or temporary?" \
                        --menu "Are your DNS changes permanent or temporary ?" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT \
                        1 "Temporary" 2 "Permanent" 3 "Help"\
                        2>&1 >/dev/tty)

        clear
        case $CHOICE_MODE in
                1)
                    mode="t"
                    dialog --backtitle "DNSPure Ver ${VERSION} - Explanations to choose better :)" --msgbox "Temporary DNS changed to ${dns_provider}." 15 60
                    exit
                    ;;
                2)
                    mode="p" 
                    dialog --backtitle "DNSPure Ver ${VERSION} - Explanations to choose better :)" --msgbox "Primary DNS changed to ${dns_provider}." 15 60
                    exit
                    ;;
                3)
                    dialog --backtitle "DNSPure Ver ${VERSION} - Permanent or temporary?" --msgbox " Temporary - your DNS will be replaced after the Restart.\n Permanent - your DNS will not change after the Restart." 15 65
                    exit
                    ;;
                *)
                    exit
                    ;;
        esac
        mv /etc/dialogrc.bak /etc/dialogrc

fi


if [ "$2" = "t" ] ; then

    mode=${2:-t} 

elif [ "$2" = "p" ]; then    
    mode=${2:-t} 
fi


if [ "$1" != "menu" ]; then 

    dns_provider=$(echo "$1" | tr '[:lower:]' '[:upper:]')

fi

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo " "
    echo "Usage: $0 <DNS_PROVIDER> [t|p] or use $0 menu"
    echo " "
    exit 
fi


systemd_resolve="/etc/systemd/resolved.conf"
resolv_conf="/etc/resolv.conf"

case $dns_provider in
    "SHECAN")
        output="[Resolve]\nDNS=185.51.200.2,178.22.122.100"
        resolv_conf_output="nameserver 185.51.200.2\nnameserver 178.22.122.100"
        ;;
    "CLOUDFLARE")
        output="[Resolve]\nDNS=1.1.1.1,1.0.0.1"
        resolv_conf_output="nameserver 1.1.1.1\nnameserver 1.0.0.1"
        ;;
    "ELECTRO")
        systemd_resolve_output="[Resolve]\nDNS=78.157.42.100,78.157.42.101"
        resolv_conf_output="nameserver 78.157.42.100\nnameserver 78.157.42.101"
        ;;
    "403")
        output="[Resolve]\nDNS=10.202.10.202,10.202.10.102"
        resolv_conf_output="nameserver 10.202.10.202\nnameserver 10.202.10.102"

        ;;
    "GOOGLE")
        output="[Resolve]\nDNS=8.8.8.8,8.8.4.4"
        resolv_conf_output="nameserver 8.8.8.8\nnameserver 8.8.4.4"
        ;;
    *)
        echo "Unknown DNS provider: $dns_provider"
        exit 
        ;;
esac


if [ "$mode" != "t" ] && [ "$mode" != "p" ]; then
    echo "Invalid mode: $mode. Defaulting to temporary mode (t)."
    mode="t"
fi

if [ "$mode" = "p" ]; then

    echo $output > "/etc/systemd/resolved.conf"
    sudo systemctl restart systemd-resolved
    echo "Primary DNS changed to $dns_provider in /etc/systemd/resolved.conf"

elif [ "$mode" = "t" ]; then

    echo $resolv_conf_output > "/etc/resolv.conf"
    echo "Temporary DNS changed to $dns_provider in /etc/resolv.conf"
fi

cp dnspure.sh /bin/dnspure
chmod +x /bin/dnspure
rm dnspure.sh
