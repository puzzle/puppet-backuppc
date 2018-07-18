# == Class: backuppc::server
#
# This module manages backuppc
#
# === Parameters
#
# [*ensure*]
# Present or absent
#
# [*service_enable*]
# Boolean. Will enable service at boot
# and ensure a running service.
#
# [*wakeup_schedule*]
# Times at which we wake up, check all the PCs,
# and schedule necessary backups. Times are measured
# in hours since midnight. Can be fractional if
# necessary (eg: 4.25 means 4:15am).
#
# [*max_backups*]
# Maximum number of simultaneous backups to run. If
# there are no user backup requests then this is the
# maximum number of simultaneous backups.
#
#[*cgi_admin_user_group*]
#[*cgi_admin_users*]
#The administrative users are the union of the unix/linux
#group $Conf{CgiAdminUserGroup} and the manual list of users,
#separated by spaces, in $Conf{CgiAdminUsers}.
#If you don't want a group or manual list of users set the
#corresponding configuration setting to undef or an empty string.
#
#[*language*]
#
#Language to use. See lib/BackupPC/Lang for the list of
#supported languages, which include English (en), French (fr),
#Spanish (es), German (de), Italian (it), Dutch (nl), Polish (pl),
#Portuguese Brazillian (pt_br) and Chinese (zh_CH).
# cz, de, en, es, fr, it, nl, pl, pt_br, zh_CN
#
#Currently the Language setting applies to the CGI interface and email
#messages sent to users. Log files and other text are still in English.
# [*cgi_url*]
#    URL of the BackupPC_Admin CGI script. Used for email messages.
#
# [*cgi_image_dir_url*]
#   URL (without the leading http://host) for BackupPC's image directory. The CGI script uses this value to serve up image files.
#   Example:
#       $Conf{CgiImageDirURL} = '/BackupPC';
#
# [*cgi_date_format_mmdd*]
#   Date display format for CGI interface. A value of 1 uses US-style dates (MM/DD), a value of 2 uses full YYYY-MM-DD format, and zero for international dates (DD/MM).
#
# [*max_user_backups*]
# Additional number of simultaneous backups that users
# can run. As many as $Conf{MaxBackups} + $Conf{MaxUserBackups}
# requests can run at the same time.
#
# [*max_pending_cmds*]
# Maximum number of pending link commands. New backups will only
# be started if there are no more than $Conf{MaxPendingCmds} plus
# $Conf{MaxBackups} number of pending link commands, plus running
# jobs. This limit is to make sure BackupPC doesn't fall too far
# behind in running BackupPC_link commands.
#
# [*max_backup_pc_nightly_jobs*]
# How many BackupPC_nightly processes to run in parallel. Each night,
# at the first wakeup listed in $Conf{WakeupSchedule}, BackupPC_nightly
# is run. Its job is to remove unneeded files in the pool, ie: files that
# only have one link. To avoid race conditions, BackupPC_nightly and BackupPC_link
# cannot run at the same time. Starting in v3.0.0, BackupPC_nightly can run
# concurrently with backups (BackupPC_dump).
#
# [*backup_pc_nightly_period*]
# How many days (runs) it takes BackupPC_nightly to traverse the entire pool.
# Normally this is 1, which means every night it runs, it does traverse the entire
# pool removing unused pool files.
#
# [*max_old_log_files*]
# Maximum number of log files we keep around in log directory. These files are aged
# nightly. A setting of 14 means the log directory will contain about 2 weeks of old
# log files, in particular at most the files LOG, LOG.0, LOG.1, ... LOG.13 (except today's
# LOG, these files will have a .z extension if compression is on).
#
# [*df_max_usage_pct*]
# Maximum threshold for disk utilization on the __TOPDIR__ filesystem. If the output
# from $Conf{DfPath} reports a percentage larger than this number then no new regularly
# scheduled backups will be run. However, user requested backups (which are usually
# incremental and tend to be small) are still performed, independent of disk usage. Also,
# currently running backups will not be terminated when the disk usage exceeds this number.
#
# [*dhcp_address_ranges*]
# List of DHCP address ranges we search looking for PCs to backup. This is an array of
# hashes for each class C address range. This is only needed if hosts in the conf/hosts
# file have the dhcp flag set.
#
# [*full_period*]
# Minimum period in days between full backups. A full dump will only be done if at least
# this much time has elapsed since the last full dump, and at least $Conf{IncrPeriod}
# days has elapsed since the last successful dump.
#
# [*full_keep_cnt*]
# Number of full backups to keep.
#
# [*full_age_max*]
# Very old full backups are removed after $Conf{FullAgeMax} days. However, we keep
# at least $Conf{FullKeepCntMin} full backups no matter how old they are.
#
# [*incr_period*]
# Minimum period in days between incremental backups (a user requested incremental
# backup will be done anytime on demand).
#
# [*incr_keep_cnt*]
# Number of incremental backups to keep.
#
# [*incr_age_max*]
# Very old incremental backups are removed after $Conf{IncrAgeMax} days. However,
# we keep at least $Conf{IncrKeepCntMin} incremental backups no matter how old
# they are.
#
# [*restore_info_keep_cnt*]
# Number of restore logs to keep. BackupPC remembers information about each restore
# request. This number per client will be kept around before the oldest ones are pruned.
#
# [*archive_info_keep_cnt*]
# Number of archive logs to keep. BackupPC remembers information about each archive request.
# This number per archive client will be kept around before the oldest ones are pruned.
#
# [*blackout_good_cnt*]
# PCs that are always or often on the network can be backed up after hours, to reduce PC,
# network and server load during working hours. For each PC a count of consecutive good
# pings is maintained. Once a PC has at least $Conf{BlackoutGoodCnt} consecutive good pings
# it is subject to "blackout" and not backed up during hours and days specified by $Conf{BlackoutPeriods}.
#
# [*blackout_zero_files_is_fatal*]
# Boolean. A backup of a share that has zero files is considered fatal. This is used to catch miscellaneous Xfer
# errors that result in no files being backed up. If you have shares that might be
# empty (and therefore an empty backup is valid) you should set this to false.
#
# [*rsync_ssh_args*]
# Array. Passes the ssh arguments like login user and escape_char. Default: '-e', '$sshPath -l backup'
#
# [*rsync_ssh_args*]
# [*rsync_full_extra_args*]
# [*rsync_args*]
# [*rsync_args_extra*]
# [*rsync_restore_args*]
# Array. Corresponding to their CamelCased Options. Defaults from Standard config.
#
# [*ref_cnt_fsck*]
# Reference counts of pool files are computed per backup by accumulating
# the relative changes. Default: 1 is the recommended setting.
#
# [*rsync_backuppc_path*]
# Full path to rsync_bpc on the server. Rsync_bpc is the customized version of rsync that is used on the server for rsync and rsyncd transfers.
#
# [*email_notify_min_days*]
# Minimum period between consecutive emails to a single user. This tries to keep annoying email to users to
# a reasonable level.
#
# [*email_from_user_name*]
# Name to use as the "from" name for email.
#
# [*email_admin_user_name*]
# Destination address to an administrative user who will receive a nightly email with warnings and errors.
#
# [*email_destination_domain*]
# Destination domain name for email sent to users.
#
# [*email_notify_old_backup_days*]
# How old the most recent backup has to be before notifying user. When there have been no backups in this
# number of days the user is sent an email.
#
# [*email_headers*]
# Additional email headers.
#
# [*apache_configuration*]
# Boolean. Whether to install the apache configuration file that creates an alias for the /backuppc url.
# Disable this if you intend to install backuppc as a virtual host yourself.
#
# [*apache_allow_from*]
# A space seperated list of hostnames, ip addresses and networks that are permitted to
# access the backuppc interface.
#
# [*apache_require_ssl*]
# This directive forbids access unless HTTP over SSL (i.e. HTTPS) is used. Relies on mod_ssl.
#
# [*backuppc_password*]
# Password for the backuppc user used to access the web interface.
#
# [*user_cmd_check_status*]
#    boolean
#    Whether the exit status of each PreUserCmd and PostUserCmd is checked.
#    If set and the Dump/Restore/Archive Pre/Post UserCmd returns a non-zero exit status then the dump/restore/archive is aborted. To maintain backward compatibility (where the exit status in early versions was always ignored), this flag defaults to 0.
#    If this flag is set and the Dump/Restore/Archive PreUserCmd fails then the matching Dump/Restore/Archive PostUserCmd is not executed. If DumpPreShareCmd returns a non-exit status, then DumpPostShareCmd is not executed, but the DumpPostUserCmd is still run (since DumpPreUserCmd must have previously succeeded).
#    An example of a DumpPreUserCmd that might fail is a script that snapshots or dumps a database which fails because of some database error.
#
# [*topdir*]
# Overwrite package default location for backuppc.
#
# [*rrdtool_path*]
# If you installed/compiled backuppc before rrdtool you can specify the rrdtool path.
#
# [*pingmaxmsec*]
# Maximum RTT value (in ms) above which backup won't be started. Default to 20ms
#
# [*manage_ssh*]
# Default: true
# Manage sshkey export and collection
#
# [*tidy_hosts_file*]
# Default: true
# Remove entries in hosts file that are not managed by puppet anymore.
#
# === Examples
#
#  See tests folder.
#
# === Authors
#
# Scott Barr <gsbarr@gmail.com>
#
class backuppc::server (
  $ensure                     = 'present',
  $service_enable             = true,
  $wakeup_schedule            = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23],
  $max_backups                = 4,
  $max_user_backups           = 4,
  $language                   = 'en',
  $max_pending_cmds           = 15,
  $max_backup_pc_nightly_jobs = 2,
  $backup_pc_nightly_period   = 1,
  $max_old_log_files          = 14,
  $df_max_usage_pct           = 95,
  $dhcp_address_ranges        = [],
  $rsync_backuppc_path        = '/usr/local/bin/rsync_bpc',
  $full_period                = '6.97',
  $full_keep_cnt              = [1],
  $full_age_max               = 90,
  $incr_period                = '0.97',
  $incr_keep_cnt              = 6,
  $incr_age_max               = 30,
  $restore_info_keep_cnt      = 10,
  $archive_info_keep_cnt      = 10,
  $blackout_good_cnt          = 7,
  $cgi_url                    = '"http://".$Conf{ServerHost}."/backuppc/index.cgi"',
  $blackout_periods           = [ { hourBegin =>  7.0,
                                    hourEnd   => 19.5,
                                    weekDays  => [1, 2, 3, 4, 5],
                                }, ],
  $blackout_zero_files_is_fatal = true,
  $rsync_ssh_args             = [ '-e', "\$sshPath -l backup" ],
  $rsync_full_extra_args      = [
        '--checksum',
  ],
  $rsync_args                 = [
        '--super',
        '--recursive',
        '--protect-args',
        '--numeric-ids',
        '--perms',
        '--owner',
        '--group',
        '-D',
        '--times',
        '--links',
        '--hard-links',
        '--delete',
        '--delete-excluded',
        '--one-file-system',
        '--partial',
        '--log-format=log: %o %i %B %8U,%8G %9l %f%L',
        '--stats',
        #
        # Add additional arguments here, for example --acls or --xattrs
        # if all the clients support them.
        #
        #'--acls',
        #'--xattrs',
  ],
  $rsync_args_extra           = [],
  $rsync_restore_args = [
        '--recursive',
        '--super',
        '--protect-args',
        '--numeric-ids',
        '--perms',
        '--owner',
        '--group',
        '-D',
        '--times',
        '--links',
        '--hard-links',
        '--delete',
        '--partial',
        '--log-format=log: %o %i %B %8U,%8G %9l %f%L',
        '--stats',
        #
        # Add additional arguments here, for example --acls or --xattrs
        # if all the clients support them.
        #
        #'--acls',
        #'--xattrs',
  ],
  $ref_cnt_fsck               = 1,
  $email_notify_min_days      = 2.5,
  $email_from_user_name       = 'backuppc',
  $email_admin_user_name      = 'backuppc',
  $email_destination_domain   = '',
  $email_notify_old_backup_days = 7,
  $email_headers              = { 'MIME-Version' => 1.0,
                                  'Content-Type' => 'text/plain; charset="utf-8"', },
  $apache_configuration       = true,
  $apache_allow_from          = 'all',
  $apache_require_ssl         = false,
  $backuppc_password          = '',
  $topdir                     = $backuppc::params::topdir,
  $rrdtool_path               = '',
  $cgi_image_dir_url          = $backuppc::params::cgi_image_dir_url,
  $cgi_admin_users            = 'backuppc',
  $cgi_admin_user_group       = 'backuppc',
  $cgi_date_format_mmdd       = 1,
  $user_cmd_check_status      = true,
  $pingmaxmsec                = 20,
  $manage_ssh                 = true,
  $tidy_hosts_file            = true,
) inherits backuppc::params  {

  if empty($backuppc_password) {
    fail('Please provide a password for the backuppc user. This is used to login to the web based administration site.')
  }
  validate_bool($service_enable)
  validate_bool($apache_require_ssl)

  validate_re($ensure, '^(present|absent)$',
  'ensure parameter must have a value of: present or absent')

  validate_re("${max_backups}", '^[1-9]([0-9]*)?$',
  'Max_backups parameter should be a number')

  validate_re("${max_user_backups}", '^[1-9]([0-9]*)?$',
  'Max_user_backups parameter should be a number')

  validate_re("${max_pending_cmds}", '^[1-9]([0-9]*)?$',
  'Max_pending_cmds parameter should be a number')

  validate_re("${max_backup_pc_nightly_jobs}", '^[1-9]([0-9]*)?$',
  'Max_backup_pc_nightly_jobs parameter should be a number')

  validate_re("${df_max_usage_pct}", '^[1-9]([0-9]*)?$',
  'Df_max_usage_pct parameter should be a number')

  validate_re("${max_old_log_files}", '^[1-9]([0-9]*)?$',
  'Max_old_log_files parameter should be a number')

  validate_re("${backup_pc_nightly_period}", '^[1-9]([0-9]*)?$',
  'Backup_pc_nightly_period parameter should be a number')

  validate_re("${full_period}", '^[0-9]([0-9]*)?(\.[0-9]{1,2})?$',
  'Full_period parameter should be a number')

  validate_re("${incr_period}", '^[0-9]([0-9]*)?(\.[0-9]{1,2})?$',
  'Incr_period parameter should be a number')

  validate_re("${full_age_max}", '^[1-9]([0-9]*)?$',
  'Full_age_max parameter should be a number')

  validate_re("${incr_keep_cnt}", '^[1-9]([0-9]*)?$',
  'Incr_keep_cnt parameter should be a number')

  validate_re("${incr_age_max}", '^[1-9]([0-9]*)?$',
  'Incr_age_max parameter should be a number')

  validate_re("${restore_info_keep_cnt}", '^[1-9]([0-9]*)?$',
  'Restore_info_keep_cnt parameter should be a number')

  validate_re("${archive_info_keep_cnt}", '^[1-9]([0-9]*)?$',
  'Restore_info_keep_cnt parameter should be a number')

  validate_re("${blackout_good_cnt}", '^[1-9]([0-9]*)?$',
  'Blackout_good_cnt parameter should be a number')

  validate_re("${email_notify_min_days}", '^[0-9]([0-9]*)?(\.[0-9]{1,2})?$',
  'Email_notify_min_days parameter should be a number')

  validate_re("${email_notify_old_backup_days}", '^[1-9]([0-9]*)?$',
  'Blackout_good_cnt parameter should be a number')

  validate_re("${cgi_date_format_mmdd}", '^[012]$',
  'Cgi_date_format_mmdd parameter should be 0-2')

  validate_re("${pingmaxmsec}", '^[1-9]([0-9]*)?$',
  'pingmaxmsec parameter should be a number')

  validate_array($wakeup_schedule)
  validate_array($dhcp_address_ranges)
  validate_array($blackout_periods)
  validate_array($full_keep_cnt)

  validate_hash($email_headers)

  validate_string($apache_allow_from)
  validate_string($cgi_url)
  validate_string($cgi_image_dir_url)
  validate_string($language)
  validate_string($cgi_admin_user_group)
  validate_string($cgi_admin_users)

  $real_bzfif     = bool2num($blackout_zero_files_is_fatal)
  $real_uccs      = bool2num($user_cmd_check_status)

  $real_topdir = $topdir ? {
    ''      => $backuppc::params::topdir,
    default => $topdir,
  }

  # On Debian, adapt log_directory to $topdir value
  $real_log_directory = $::osfamily ? {
    'Debian' => "${topdir}/log",
    default  => $backuppc::params::log_directory,
  }

  # If topdir is changed, create a symlink between "default" topdir and the custom
  # This permit "facter/backuppc_pubkey_rsa" to work properly.
  if $real_topdir != $backuppc::params::topdir {
    file { $backuppc::params::topdir:
      ensure => link,
      target => $real_topdir,
    }
  }

  # Set up dependencies
  Package[$backuppc::params::package] -> File[$backuppc::params::config] -> Service[$backuppc::params::service]

  # Include preseeding for debian packages
  if $::osfamily == 'Debian' {
    file { '/var/cache/debconf/backuppc.seeds':
      ensure => $ensure,
      source => 'puppet:///modules/backuppc/backuppc.preseed',
    }
  }

  # BackupPC package and service configuration
  package { $backuppc::params::package:
    ensure  => $ensure,
  }

  service { $backuppc::params::service:
    ensure    => $service_enable,
    enable    => $service_enable,
    hasstatus => true,
    pattern   => 'BackupPC'
  }

  file { $backuppc::params::config:
    ensure  => $ensure,
    owner   => 'backuppc',
    group   => $backuppc::params::group_apache,
    mode    => '0640',
    content => template('backuppc/config.pl.erb'),
    notify  => Service[$backuppc::params::service]
  }

  file { $backuppc::params::config_directory:
    ensure  => $ensure,
    owner   => 'backuppc',
    group   => $backuppc::params::group_apache,
    require => Package[$backuppc::params::package],
  }

  file { "${backuppc::params::config_directory}/pc":
    ensure  => link,
    target  => $backuppc::params::config_directory,
    require => Package[$backuppc::params::package],
  }

  file { [$real_topdir, "${real_topdir}/.ssh"]:
    ensure  => 'directory',
    owner   => 'backuppc',
    group   => $backuppc::params::group_apache,
    mode    => '0640',
    require => Package[$backuppc::params::package],
    ignore  => 'BackupPC.sock',
  }

  # Workaround for client exported resources that are
  # on a different osfamily. Maintain a symlink to alternative
  # config directory targets.
  case $::osfamily {
    'Debian': {
      file { '/etc/BackupPC':
        ensure => link,
        target => $backuppc::params::config_directory,
      }
    }
    'RedHat': {
      file { '/etc/backuppc':
        ensure => link,
        target => $backuppc::params::config_directory,
      }
    }
    default: {
      notify { "If you've added support for ${::operatingsystem} you'll need to extend this case statement to.":
      }
    }
  }

  # BackupPC apache configuration
  if $apache_configuration {
    file { $backuppc::params::config_apache:
      ensure  => $ensure,
      content => template("backuppc/apache_${::osfamily}.erb"),
      require => Package[$backuppc::params::package],
    }

    # Create the default admin account
    backuppc::server::user { 'backuppc':
      password => $backuppc_password
    }
  }

  if $tidy_hosts_file {
    # Since we now tag the hosts that are managed by
    # puppet, check the current hosts file and compare
    # it with what is in puppetdb.
    $dbhosts = query_nodes("Class[backuppc::client]{backuppc_hostname=\"${::fqdn}\"}")
    $hostsstr = join(sort($dbhosts), '')

    exec { 'tidy_hosts_file':
      command     => "sed -i '/#puppetmanaged$/d' ${backuppc::params::hosts}",
      environment => ['LC_ALL=C'],
      path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      unless      => "test \"$(sed -rn '/#puppetmanaged/ s/^([^ ]+).*/\\1/p' ${backuppc::params::hosts} | sort | tr -d '\\n')\" = \"${hostsstr}\"",
    } -> File_line <<| tag == "backuppc_hosts_${::fqdn}" |>>
  }

  # Hosts
  File <<| tag == "backuppc_config_${::fqdn}" |>> {
    group   => $backuppc::params::group_apache,
    notify  => Service[$backuppc::params::service],
    require => File["${backuppc::params::config_directory}/pc"],
  }
  File_line <<| tag == "backuppc_hosts_${::fqdn}" |>> {
    require => Package[$backuppc::params::package],
    notify  => Service[$backuppc::params::service],
  }

  if $manage_ssh { include backuppc::server::ssh }
}
