# == Class: backuppc::client::ssh
#
# ssh key and authorized key
#
# === Parameters
#
# [*export_hostkey*]
# Set this to false if you already deploy the clients hostkey to the server
#
# === Authors
#
# Scott Barr <gsbarr@gmail.com>
# Philipp Gassmann <gassmann@puzzle.ch>
#
class backuppc::client::ssh(
  $export_hostkey = true,
){
  include backuppc::client
  $ensure                = $backuppc::client::ensure
  $system_account        = $backuppc::client::system_account
  $system_home_directory = $backuppc::client::system_home_directory
  $backuppc_hostname     = $backuppc::client::backuppc_hostname

  $directory_ensure = $ensure ? {
    'present' => 'directory',
    default   => absent,
  }
  file { "${system_home_directory}/.ssh":
    ensure => $directory_ensure,
    mode   => '0700',
    owner  => $system_account,
    group  => $system_account,
  }
  Ssh_authorized_key <<| tag == "backuppc_${backuppc_hostname}" |>> {
    ensure  => $ensure,
    user    => $system_account,
    require => File["${system_home_directory}/.ssh"]
  }

  if $export_hostkey {
    @@sshkey { $::fqdn:
      ensure => $ensure,
      type   => 'ssh-rsa',
      key    => $::sshrsakey,
      tag    => "backuppc_sshkeys_${backuppc_hostname}",
    }
  }
}
