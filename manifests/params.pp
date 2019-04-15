# PHP params class
#
class php::params inherits php::globals {

  $ensure              = 'present'
  $fpm_service_enable  = true
  $fpm_service_ensure  = 'running'
  $composer_source     = 'https://getcomposer.org/composer.phar'
  $composer_path       = '/usr/local/bin/composer'
  $composer_max_age    = 30
  $pear_ensure         = 'present'
  $pear_package_suffix = 'pear'
  $phpunit_source      = 'https://phar.phpunit.de/phpunit.phar'
  $phpunit_path        = '/usr/local/bin/phpunit'
  $phpunit_max_age     = 30
  $pool_purge          = false

  case $facts['os']['family'] {
    'Debian': {
      $config_root             = $php::globals::globals_config_root
      $config_root_ini         = "${config_root}/mods-available"
      $config_root_inifile     = "${config_root}/php.ini"
      $common_package_names    = []
      $common_package_suffixes = ['cli', 'common']
      $cli_inifile             = "${config_root}/cli/php.ini"
      $dev_package_suffix      = 'dev'
      $fpm_pid_file            = $php::globals::globals_fpm_pid_file
      $fpm_config_file         = "${config_root}/fpm/php-fpm.conf"
      $fpm_error_log           = $php::globals::fpm_error_log
      $fpm_inifile             = "${config_root}/fpm/php.ini"
      $fpm_package_suffix      = 'fpm'
      $fpm_pool_dir            = "${config_root}/fpm/pool.d"
      $fpm_service_name        = $php::globals::fpm_service_name
      $fpm_user                = 'www-data'
      $fpm_group               = 'www-data'
      $apache_inifile          = "${config_root}/apache2/php.ini"
      $embedded_package_suffix = 'embed'
      $embedded_inifile        = "${config_root}/embed/php.ini"
      $package_prefix          = $php::globals::package_prefix
      $compiler_packages       = 'build-essential'
      $root_group              = 'root'
      $ext_tool_enable         = $php::globals::ext_tool_enable
      $ext_tool_query          = $php::globals::ext_tool_query
      $ext_tool_enabled        = true

      case $facts['os']['name'] {
        'Debian': {
          $manage_repos = (versioncmp($facts['os']['release']['major'], '8') < 0)
        }

        'Ubuntu': {
          $manage_repos = false
        }

        default: {
          $manage_repos = false
        }
      }
    }

    'Suse': {
      if ($php::globals::php_version != undef) {
        $php_version_major = regsubst($php::globals::php_version, '^(\d+)\.(\d+)$','\1')
      } else {
        $php_version_major = 5
      }

      $config_root             = $php::globals::globals_config_root
      $config_root_ini         = "${config_root}/conf.d"
      $config_root_inifile     = "${config_root}/php.ini"
      $common_package_names    = ["php${php_version_major}"]
      $common_package_suffixes = []
      $cli_inifile             = "${config_root}/cli/php.ini"
      $dev_package_suffix      = 'devel'
      $fpm_pid_file            = $php::globals::globals_fpm_pid_file
      $fpm_config_file         = "${config_root}/fpm/php-fpm.conf"
      $fpm_error_log           = $php::globals::fpm_error_log
      $fpm_inifile             = "${config_root}/fpm/php.ini"
      $fpm_package_suffix      = 'fpm'
      $fpm_pool_dir            = "${config_root}/fpm/pool.d"
      $fpm_service_name        = 'php-fpm'
      $fpm_user                = 'wwwrun'
      $fpm_group               = 'www'
      $embedded_package_suffix = 'embed'
      $embedded_inifile        = "${config_root}/embed/php.ini"
      $package_prefix          = $php::globals::package_prefix
      $manage_repos            = true
      $root_group              = 'root'
      $ext_tool_enable         = undef
      $ext_tool_query          = undef
      $ext_tool_enabled        = false
      case $facts['os']['name'] {
        'SLES': {
          $compiler_packages = []
        }
        'OpenSuSE': {
          $compiler_packages = 'devel_basis'
        }
        default: {
          fail("Unsupported operating system ${facts['os']['name']}")
        }
      }
    }
    'RedHat': {
      $config_root      = $php::globals::globals_config_root

      case $php::globals::rhscl_mode {
        'remi': {
          $config_root_ini         = "${config_root}/php.d"
          $config_root_inifile     = "${config_root}/php.ini"
          $cli_inifile             = $config_root_inifile
          $fpm_inifile             = $config_root_inifile
          $fpm_config_file         = "${config_root}/php-fpm.conf"
          $fpm_pool_dir            = "${config_root}/php-fpm.d"
          $php_bin_dir             = "${php::globals::rhscl_root}/bin"
        }
        'rhscl': {
          $config_root_ini         = "${config_root}/php.d"
          $config_root_inifile     = "${config_root}/php.ini"
          $cli_inifile             = "${config_root}/php-cli.ini"
          $fpm_inifile             = "${config_root}/php-fpm.ini"
          $fpm_config_file         = "${config_root}/php-fpm.conf"
          $fpm_pool_dir            = "${config_root}/php-fpm.d"
          $php_bin_dir             = "${php::globals::rhscl_root}/bin"
        }
        undef: {
          # no rhscl
          $config_root_ini         = $config_root
          $config_root_inifile     = '/etc/php.ini'
          $cli_inifile             = '/etc/php-cli.ini'
          $fpm_inifile             = '/etc/php-fpm.ini'
          $fpm_config_file         = '/etc/php-fpm.conf'
          $fpm_pool_dir            = '/etc/php-fpm.d'
        }
        default: {
          fail("Unsupported rhscl_mode '${php::globals::rhscl_mode}'")
        }
      }

      $apache_inifile          = $config_root_inifile
      $embedded_inifile        = $config_root_inifile
      $common_package_names    = []
      $common_package_suffixes = ['cli', 'common']
      $dev_package_suffix      = 'devel'
      $fpm_pid_file            = $php::globals::globals_fpm_pid_file
      $fpm_error_log           = '/var/log/php-fpm/error.log'
      $fpm_package_suffix      = 'fpm'
      $fpm_service_name        = pick($php::globals::fpm_service_name, 'php-fpm')
      $fpm_user                = 'apache'
      $fpm_group               = 'apache'
      $embedded_package_suffix = 'embedded'
      $package_prefix          = pick($php::globals::package_prefix, 'php-')
      $compiler_packages       = ['gcc', 'gcc-c++', 'make']
      $manage_repos            = false
      $root_group              = 'root'
      $ext_tool_enable         = undef
      $ext_tool_query          = undef
      $ext_tool_enabled        = false
    }
    'FreeBSD': {
      $config_root             = $php::globals::globals_config_root
      $config_root_ini         = "${config_root}/php"
      $config_root_inifile     = "${config_root}/php.ini"
      # No common packages, because the required PHP base package will be
      # pulled in as a dependency. This preserves the ability to choose
      # any available PHP version by setting the 'package_prefix' parameter.
      $common_package_names    = []
      $common_package_suffixes = ['extensions']
      $cli_inifile             = "${config_root}/php-cli.ini"
      $dev_package_suffix      = undef
      $fpm_pid_file            = $php::globals::globals_fpm_pid_file
      $fpm_config_file         = "${config_root}/php-fpm.conf"
      $fpm_error_log           = '/var/log/php-fpm.log'
      $fpm_inifile             = "${config_root}/php-fpm.ini"
      $fpm_package_suffix      = undef
      $fpm_pool_dir            = "${config_root}/php-fpm.d"
      $fpm_service_name        = 'php-fpm'
      $fpm_user                = 'www'
      $fpm_group               = 'www'
      $embedded_package_suffix = 'embed'
      $embedded_inifile        = "${config_root}/php-embed.ini"
      $package_prefix          = 'php56-'
      $compiler_packages       = ['gcc']
      $manage_repos            = false
      $root_group              = 'wheel'
      $ext_tool_enable         = undef
      $ext_tool_query          = undef
      $ext_tool_enabled        = false
    }
    'Archlinux': {
      $config_root_ini         = '/etc/php/conf.d'
      $config_root_inifile     = '/etc/php/php.ini'
      $common_package_names    = []
      $common_package_suffixes = []
      $cli_inifile             = '/etc/php/php.ini'
      $dev_package_suffix      = undef
      $fpm_pid_file            = '/run/php-fpm/php-fpm.pid'
      $fpm_config_file         = '/etc/php/php-fpm.conf'
      $fpm_error_log           = 'syslog'
      $fpm_inifile             = '/etc/php/php.ini'
      $fpm_package_suffix      = 'fpm'
      $fpm_pool_dir            = '/etc/php/php-fpm.d'
      $fpm_service_name        = 'php-fpm'
      $fpm_user                = 'root'
      $fpm_group               = 'root'
      $apache_inifile          = '/etc/php/php.ini'
      $embedded_package_suffix = 'embedded'
      $embedded_inifile        = '/etc/php/php.ini'
      $package_prefix          = 'php-'
      $compiler_packages       = ['gcc', 'make']
      $manage_repos            = false
      $root_group              = 'root'
      $ext_tool_enable         = undef
      $ext_tool_query          = undef
      $ext_tool_enabled        = false
    }
    default: {
      fail("Unsupported osfamily: ${facts['os']['family']}")
    }
  }
}
