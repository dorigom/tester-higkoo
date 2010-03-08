#!/bin/bash
nowTime=`date '+%Y%m%d%H%M%S'`
profileFile="/etc/profile"
inittabFile="/etc/inittab"

# �޸��ļ���������С
cp ${profileFile} ${profileFile}.${nowTime}.bak
echo "����${profileFile} --> ${profileFile}.${nowTime}.bak"
grep "ulimit" ${profileFile} > /dev/null
if [ $? -eq 1 ]
then
	echo "ulimit -n 81920" >> ${profileFile}
else
	sed -i '/ulimit/'d ${profileFile}
	echo "ulimit -n 81920">> ${profileFile}
	source ${profileFile}
fi

# ����������ͼ�ν���
cp ${inittabFile} ${inittabFile}.${nowTime}.bak
echo "����${inittabFile} --> ${inittabFile}.${nowTime}.bak"
sed -i 's/\(id\):[0-6]/\1:3/g' ${inittabFile}
echo 'Chang ${inittabFile} to "Full multiuser mode", id=3 .'

# ����ϵͳ����ʱ�ķ���
chkconfig bluetooth off
chkconfig iptables off
chkconfig ip6tables off
chkconfig sendmail off
chkconfig vncserver on
chkconfig yum-updatesd off
# ��װJDK
setupFile="/data/setupfiles/jdk-6u12-linux-i586.bin"
extractDir="/data/programfiles/"
linkDir="/usr/local/jdk"

cd ${extractDir}
chmod +x ${setupFile}
ls ${extractDir} > /tmp/s.ls
${setupFile}
ls ${extractDir} > /tmp/t.ls
#  ͨ���Ƚ�Ŀ¼��ȷ����ѹĿ¼
verName=`comm -13 /tmp/s.ls /tmp/t.ls`
rm -f /tmp/s.ls /tmp.t.ls
programDir="/data/programfiles/"${verName}

ln -s ${programDir} ${linkDir}
# ���JAVA_HOME����������
cp ${profileFile} ${profileFile}.${nowTime}.bak
echo "����${profileFile} --> ${profileFile}.${nowTime}.bak"
grep "JAVA_HOME" ${profileFile} > /dev/null
if [ $? -eq 1 ]
then
        echo "JAVA_HOME=/usr/local/jdk" >> ${profileFile}
else
        sed -i '/JAVA_HOME/'d ${profileFile}
        echo "JAVA_HOME=/usr/local/jdk">> ${profileFile}
        source ${profileFile}
fi
# ���java��Path
which java
if [ $? -eq 1 ]
then
        export PATH=$PATH:$JAVA_HOME/bin
fi
#  �޸�Ӧ�ó����JAVA_HOME=/usr/local/jdk

# ��װApache
setupFile="/data/setupfiles/httpd-2.2.11.tar.bz2"
extractDir="/data/setupfiles/"
#  ʹ��tar�鿴��ѹ���Ŀ¼��
verName=`tar -jtf ${setupFile} | head -1`
setupDir="/data/setupfiles/"${verName}
programDir="/data/programfiles/"${verName}
linkDir="/usr/local/apache2"

tar -jxvf ${setupFile} -C ${extractDir}
cd ${setupDir}
make clean
./configure --prefix=${programDir} 
make
make install

ln -s ${programDir} ${linkDir}
# ��ѯ����ʵ����
ps -A | grep httpd
# ������������ѡһ�֣�
/usr/local/apache2/bin/apachectl -k start
/usr/local/apache2/bin/httpd
# ֹͣ����ѡһ�֣�
/usr/local/apache2/bin/apachectl -k stop
killall -9 httpd

# ж�أ���ֹͣ����
#  ����һ���ڰ�װ���̵�make��ִ�У�
make uninstall
#  ��������ֱ��ɾ����װĿ¼���ɣ�
rm -f ${linkDir}
rm -rf ${programDir}

# ��װJboss
setupFile="/data/setupfiles/jboss-4.2.3.GA.zip"
extractDir="/data/programfiles/"
# ʹ��unzip��ʾ��ѹ���Ŀ¼
verName=`unzip -l ${setupFile} | awk '{if(NR==4)print $4}'`
programDir="/data/programfiles/"${verName}
linkDir="/usr/local/jboss"

unzip ${setupFile} -d ${extractDir}
ln -s ${programDir} ${linkDir}

# ��ѯ����ʵ��
ps -aux | grep jboss
# ����������
/usr/local/jboss/bin/run.sh
# ֹͣ��������ѡһ�֣�
/usr/local/jboss/bin/shutdown.sh
kill -9 `ps aux | grep jboss | cut -c9-14` 2>/dev/null
# ж�أ���ֹͣ����ֱ��ɾ����װĿ¼���ɣ���
rm -f ${linkDir}
rm -rf ${programDir}