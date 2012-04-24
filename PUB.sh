#!/bin/env echo "Warning: this file should be sourced"
set -e
if [ "$PUB_HEAD_DEF" != "PUB_HEAD_DEF" ]; then
  [ -f $HOME/.hadoop_profile ] && . $HOME/.hadoop_profile

  OLDDIR=`pwd`
  DIR=`cd $(dirname $0);pwd`
  if [ `uname -m | sed -e 's/i.86/32/'` == '32' ]; then
    alias IS_32='true';
  else
    alias IS_32='false'
  fi
  PUB_HEAD_DEF="PUB_HEAD_DEF"

  show_head()
  {
    echo "========================================================================================="
    echo ""
    echo "@   @  @@@  @@@@   @@@   @@@  @@@@        @@@@  @@@@@ @@@@  @      @@@  @   @ @@@@@ @@@@"
    echo "@   @ @   @ @   @ @   @ @   @ @   @       @   @ @     @   @ @     @   @ @   @ @     @   @"
    echo "@   @ @   @ @   @ @   @ @   @ @   @       @   @ @     @   @ @     @   @  @ @  @     @   @"
    echo "@@@@@ @@@@@ @   @ @   @ @   @ @@@@        @   @ @@@@  @@@@  @     @   @   @   @@@@  @@@@"
    echo "@   @ @   @ @   @ @   @ @   @ @           @   @ @     @     @     @   @   @   @     @ @"
    echo "@   @ @   @ @   @ @   @ @   @ @           @   @ @     @     @     @   @   @   @     @  @"
    echo "@   @ @   @ @@@@   @@@   @@@  @           @@@@  @@@@@ @     @@@@@  @@@    @   @@@@@ @   @"
    echo ""
    echo "V0.1 by uc.cn 2012-04"
    echo ""
    echo "========================================================================================="
  }

  die() { [ $# -gt 0 ] && echo $@; exit -1; }
  var() { eval echo \$"$1"; }
  var_die() { [ "`var $1`" == "" ] && die "var $1 is not definded" ||:; }
  
  [ "$DEPLOYER_HOME" == "" ] && DEPLOYER_HOME="$HOME/hadoop-deployer" ||:;
  #var_die DEPLOYER_HOME;
  D=$DEPLOYER_HOME
  
  # $0 url.list.file
  download()
  {
    local dls=`cat $D/download.list.txt`
    mkdir -p $D/tar
    cd $D/tar
    for dl in $dls; do
      dl=`echo $dl|sed "s:\\s\\+::"`
      [ "${dl::1}" == "#" ] && continue ||:;
      wget -nv -c $dl; 
    done
    cd $OLDDIR 
  }

  # $0 cmd
  check_tool()
  {
    [ -f "`which $1`" ] && echo "$1 is exists" || die "$1 is not exists"
  }

  [ -f $D/install_env.sh ] && . $D/install_env.sh 
  
  nodes()
  {
    local TMP_F="tmp_uniq_nodes.txt.tmp";
    :>$TMP_F
    for s in $DN; do
      echo $s >> $TMP_F;
    done
    echo $NN >> $TMP_F; 
    [ "$SNN" != "" ] && echo $SNN >> $TMP_F
    export NODE_HOSTS=`sort $TMP_F | uniq`
    rm -f $TMP_F
  }

  # $0 source target 
  rsync_all()
  {
    for s in $NODE_HOSTS; do
      [ `hostname` == "$s" ] && continue 
      echo ">> rsync to $s";
      rsync -a --exclude=.svn --exclude=.git --exclude=logs $1 -e "ssh -p $SSH_PORT" $s:$2;
    done
  }

  alias ssh="ssh -p $SSH_PORT"
  alias scp="scp -P $SSH_PORT"
fi
