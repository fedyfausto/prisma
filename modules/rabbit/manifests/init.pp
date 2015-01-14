class rabbit {

  include erlang

  $hst_rab_1 = hiera('hst_rab_1')
  $hst_rab_2 = hiera('hst_rab_2')
  $hst_rab_3 = hiera('hst_rab_3')  

  package { 'erlang-base':
    ensure => latest,
  }

  exec { 'clean':
    command => 'killall -u rabbitmq && rm -rf /var/lib/rabbitmq/mnesia/*',
    path    => '/usr/local/bin/:/bin/:/sbin/:/usr/bin/',
  }

  class { 'rabbitmq':
    config_cluster           => true,
    cluster_nodes            => [$hst_rab_1, $hst_rab_2, $hst_rab_3],
    cluster_node_type        => 'ram', #disk
    erlang_cookie            => 'A_SECRET_COOKIE_STRING',
    wipe_db_on_cookie_change => true,
    environment_variables    => {
      'RABBITMQ_NODENAME'    => $hostname,
      'RABBITMQ_SERVICENAME' => 'RabbitMQ',
    },
    port                     => '5672',
    default_user             => 'root',
    default_pass             => hiera('rab_def_pwd'),
    delete_guest_user        => true,
    tcp_keepalive	     => true,
    require	             => Exec['clean'],
  }

}
