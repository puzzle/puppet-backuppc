# == Class: backuppc::server::ssh
#
# ssh key and authorized key
#
# === Authors
#
# Scott Barr <gsbarr@gmail.com>
# Philipp Gassmann <gassmann@puzzle.ch>
#
class backuppc::server::ssh{
  $real_topdir = $backuppc::server::real_topdir

  if $facts['backuppc_pubkey_rsa'] {
    # use public key from fact
    $pubkey_rsa = $facts['backuppc_pubkey_rsa']
  } else {
    # fact not yet ready, generate key
    $pubkey_rsa = undef
    exec { 'backuppc-ssh-keygen':
      command => "ssh-keygen -f ${real_topdir}/.ssh/id_rsa -C 'BackupPC on ${::fqdn}' -N ''",
      user    => 'backuppc',
      creates => "${real_topdir}/.ssh/id_rsa",
      path    => ['/usr/bin','/bin'],
      require => [
          Package[$backuppc::params::package],
          File["${real_topdir}/.ssh"],
      ],
    }
  }

  # Export backuppc's authorized key for collection by clients
  if $pubkey_rsa {
    @@ssh_authorized_key { "backuppc_${::fqdn}":
      ensure  => present,
      key     => $pubkey_rsa,
      user    => 'backup',
      options => [
        'command="~/backuppc.sh"',
        'no-agent-forwarding',
        'no-port-forwarding',
        'no-pty',
        'no-X11-forwarding',
      ],
      type    => 'ssh-rsa',
      tag     => "backuppc_${::fqdn}",
    }
  }

  # collect hostkeys
  Sshkey <<| tag == "backuppc_sshkeys_${::fqdn}" |>>
}
