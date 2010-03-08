#!/bin/bash
nowTime=`date '+%Y%m%d%H%M%S'`
ifcfgFile="/etc/sysconfig/network-scripts/ifcfg-eth0"
resolvFile="/etc/resolv.conf"
networkFile="/etc/sysconfig/network"
rollbackFile="/tmp/rollbackIP.sh"

# ����ifcfg-eth0�ļ�
echo -n "������IP��ַ��10.20.223.11"
read ip
echo "���õ�IPΪ��10.20.223.11${ip}"
cp ${ifcfgFile} ${ifcfgFile}.${nowTime}.bak
echo "����${ifcfgFile} --> ${ifcfgFile}.${nowTime}.bak"
echo -e "DEVICE=eth0\nBOOTPROTO=static\nIPADDR=10.20.223.11${ip}\nNETMASK=255.255.254.0\nGATEWAY=10.20.222.1\nTYPE=Ethernet\nONBOOT=yes" > ${ifcfgFile}

# ����resolv.conf�ļ�
cp ${resolvFile} ${resolvFile}.${nowTime}.bak
echo "����${resolvFile} --> ${resolvFile}.${nowTime}.bak"
echo -e "search localdomain\nnameserver 10.20.18.10\nnameserver 10.20.18.11" > ${resolvFile}

# ����network�ļ�
cp ${networkFile} ${networkFile}.${nowTime}.bak
echo "����${networkFile} --> ${networkFile}.${nowTime}.bak"
echo -e "NETWORKING=yes\nNETWORKING_IPV6=no\nHOSTNAME=pSrv${ip}.localdomain" > ${networkFile}

# ���ɻ�ԭ���õĽű�
echo -e "mv -f ${ifcfgFile}.${nowTime}.bak ${ifcfgFile}\nmv -f ${resolvFile}.${nowTime}.bak ${resolvFile}\nmv -f ${networkFile}.${nowTime}.bak ${networkFile}\nservice network restart" > ${rollbackFile}
chmod +x ${rollbackFile}
echo "��ԭIP������ִ�У�${rollbackFile}"

# ��������
service network restart