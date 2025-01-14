# Used for testing the recipe in a Vagrant box
#
# Login via user "admin" and password "admin"

include java

class { 'graylog::allinone':
  elasticsearch => {
    version      => '7.10.2',
  },
  graylog       => {
    major_version          => '4.2',
    config                 => {
      'password_secret'          => '16BKgz0Qelg6eFeJYh8lc4hWU1jJJmAgHlPEx6qkBa2cQQTUG300FYlPOEvXsOV4smzRtnwjHAKykE3NIWXbpL7yGLN7V2P2',
      'root_password_sha2'       => '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
      'versionchecks'            => false,
      'usage_statistics_enabled' => false,
      'http_bind_address'        => '0.0.0.0:9000',
    },
    java_initial_heap_size => '2g',
    java_max_heap_size     => '2g',
    java_opts              => '-Dcom.sun.management.jmxremote',
  }
}
