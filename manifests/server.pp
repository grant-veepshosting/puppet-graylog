class graylog::server(
  $package_version = $graylog::params::package_version,
  Hash  $config = undef,
  $user = $graylog::params::server_user,
  $group = $graylog::params::server_group,
  $ensure = running,
  $enable = true,
  $java_initial_heap_size = $graylog::params::java_initial_heap_size,
  $java_max_heap_size = $graylog::params::java_max_heap_size,
  Boolean $restart_on_package_upgrade = false,
) inherits graylog::params {
  if $config == undef {
    fail('Missing "config" setting!')
  }

  $data = merge($::graylog::params::default_config, $config)

  $notify = $restart_on_package_upgrade ? {
    true    => Service['graylog-server'],
    default => undef,
  }

  anchor { 'graylog::server::start': }
  anchor { 'graylog::server::end': }

  package { 'graylog-server':
    ensure => $package_version,
    notify => $notify,
  }

  file { '/etc/graylog/server/server.conf':
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => template("${module_name}/server/graylog.conf.erb"),
  }

  case $::osfamily {
    'debian': {
      file { '/etc/default/graylog-server':
        ensure  => file,
        owner   => $user,
        group   => $group,
        mode    => '0640',
        content => epp("${module_name}/server/environment.epp",
                      {
                        'java_initial_heap_size' => $java_initial_heap_size,
                        'java_max_heap_size'     => $java_max_heap_size
                      }),
      }
    }
    'redhat': {
      file { '/etc/sysconfig/graylog-server':
        ensure  => file,
        owner   => $user,
        group   => $group,
        mode    => '0640',
        content => epp("${module_name}/server/environment.epp",
                      {
                        'java_initial_heap_size' => $java_initial_heap_size,
                        'java_max_heap_size'     => $java_max_heap_size
                      }),
      }
    }
    default: {
      fail("${::osfamily} is not supported!")
    }
  }

  service { 'graylog-server':
    ensure     => $ensure,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
  }

  Anchor['graylog::server::start']
  ->Package['graylog-server']
  ->File['/etc/graylog/server/server.conf']
  ~>Service['graylog-server']
  ->Anchor['graylog::server::end']
}
