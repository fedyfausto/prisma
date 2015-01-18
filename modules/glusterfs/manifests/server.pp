class glusterfs::server {
  
  require glusterfs::disk
  require glusterfs::key
  
  class { 'apt':
    always_apt_update => true,
  }

  #apt::ppa { 'ppa:semiosis/ubuntu-glusterfs-3.5': }
  #->
  package { ['glusterfs-server','glusterfs-client','glusterfs-common']: 
    ensure => installed, 
  }
  
  service { 'glusterfs-server': 
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    restart    => true,
    hasrestart => true,
    path       => '/etc/init.d',
    require    => Package['glusterfs-server','glusterfs-client','glusterfs-common'],
  }
  
  #exec { 'restart spakkidemone':
  #  command => 'glusterfs-server restart',
  #  path    => '/etc/init.d/',
  #  require => Service['glusterfs-server'],
  #}
  
  #exec { 'dns clean':
  #  command => 'dns-clean restart',
  #  path    => '/etc/init.d/',
  #  require => Service['glusterfs service'],
  #}
  
  exec { 'networking reload':
    command => 'networking force-reload',
    path    => '/etc/init.d/',
    require => Service['glusterfs-server'],
  }

  
}

include glusterfs::server