#
# == Define: archive::netinstall
#
# Fetch an archive from an URL and extract it to a directory. Code derived from
# example42/puppet-modules/common.
#
define archive::netinstall
(
    $url,
    $extracted_dir,
    $destination_dir,
    $owner = "root",
    $group = "root",
    $work_dir = "/tmp",
    $extract_command = "tar -zxvf",
    $preextract_command = "",
    $postextract_command = ""
    # $postextract_command = "./configure ; make ; make install"
)
{

    $source_filename = urlfilename($url)

    $path = [ '/bin', '/usr/bin', '/usr/local/bin' ]

    if $preextract_command {
        exec { "PreExtract $source_filename":
            command => $preextract_command,
            before  => Exec["Extract $source_filename"],
            refreshonly => true,
            path => $path
        }
    }

    exec { "Retrieve $url":
        cwd     => "$work_dir",
        command => "wget $url",
        creates => "$work_dir/$source_filename",
        timeout => 3600,
        path => $path
    }

    exec { "Extract $source_filename":
        command => "mkdir -p $destination_dir && cd $destination_dir && $extract_command $work_dir/$source_filename",
        creates => "${destination_dir}/${extracted_dir}",
        require => Exec["Retrieve $url"],
        path => $path
    }

    if $postextract_command {
        exec { "PostExtract $source_filename":
            command => $postextract_command,
            cwd => "$destination_dir/$extracted_dir",
            subscribe => Exec["Extract $source_filename"],
            refreshonly => true,
            timeout => 3600,
            require => Exec["Retrieve $url"],    
            path => $path
        }
    }
}
