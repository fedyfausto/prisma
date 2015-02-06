# nodes_n -> number of galera nodes

class haproxy::install ( $nodes_n ) {
  
  case $nodes_n {
    '3': {
      $hap_tem = 'haproxy.erb'
      $ip_gal_m = hiera('ip_gal_m')
      $ip_gal_1 = hiera('ip_gal_1')
      $ip_gal_2 = hiera('ip_gal_2')
      $hst_gal_m = hiera('hst_gal_m')
      $hst_gal_1 = hiera('hst_gal_1')
      $hst_gal_2 = hiera('hst_gal_2')
    }
    '4': {
      $hap_tem = 'haproxy4.erb'
      $ip_gal_m = hiera('ip_gal_m')
      $ip_gal_1 = hiera('ip_gal_1')
      $ip_gal_2 = hiera('ip_gal_2')
      $ip_gal_3 = hiera('ip_gal_3')
      $hst_gal_m = hiera('hst_gal_m')
      $hst_gal_1 = hiera('hst_gal_1')
      $hst_gal_2 = hiera('hst_gal_2')
      $hst_gal_3 = hiera('hst_gal_3')
    }
    '5': {
      $hap_tem = 'haproxy5.erb'
      $ip_gal_m = hiera('ip_gal_m')
      $ip_gal_1 = hiera('ip_gal_1')
      $ip_gal_2 = hiera('ip_gal_2')
      $ip_gal_3 = hiera('ip_gal_3')
      $ip_gal_4 = hiera('ip_gal_4')
      $hst_gal_m = hiera('hst_gal_m')
      $hst_gal_1 = hiera('hst_gal_1')
      $hst_gal_2 = hiera('hst_gal_2')
      $hst_gal_3 = hiera('hst_gal_3')
      $hst_gal_4 = hiera('hst_gal_4')
    }
  }
  case $osfamily {
    'Debian': {
      package { 'mariadb-client': ensure => installed }

      package { 'haproxy': 
        ensure  => installed ,
        require => Package["mariadb-client"],
      }

      file { '/etc/default/haproxy':
        content => "ENABLED=1\n",
        require => Package['haproxy'],
      }

      service { 'haproxy':
        ensure  => running,
        enable  => true,
        require => Package['haproxy'],
      }
  
      file { '/etc/haproxy/haproxy.cfg':
        path    => hiera('haproxy_cnf_path'),
        content => template("haproxy/${hap_tem}"),
        ensure  => present,
        require => Package['haproxy'],
        notify  => Service['haproxy'],
      }
    }
    'RedHat': {
      package {'mysql-libs':
        ensure   => absent,
        provider => yum,
      }
        
      package {'MariaDB-client':
        ensure        => installed,
        allow_virtual => false,
        provider      => yum,
        require       => Package['mariadb-libs'],
      }
      
      package { 'haproxy': 
        ensure        => installed,
        allow_virtual => false,
        provider      => yum,
        require       => Package['MariaDB-client'],
      }
      
      exec { 'enable':
        command => "systemctl enable haproxy.service",
        path    => "/usr/local/bin/:/bin/:/sbin/:/usr/bin/",
        require => Package['haproxy'],
      }
      
      service { 'haproxy':
        ensure   => running,
        provider => systemd,
        enable   => true,
        require  => Package['haproxy'],
      }
  
      file { '/etc/haproxy/haproxy.cfg':
        path    => hiera('haproxy_cnf_path'),
        content => template("haproxy/${hap_tem}"),
        ensure  => present,
        require => Package['haproxy'],
        notify  => Service['haproxy'],
      }
      
      exec { 'config-file':
        command => 'haproxy -f /etc/haproxy/haproxy.cfg',
        path    => "/usr/local/bin/:/bin/:/sbin/:/usr/bin/",
        require => File['/etc/haproxy/haproxy.cfg'],
      }
      
    }
  }
}

include haproxy::install
