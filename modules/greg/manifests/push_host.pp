define greg::push_host ($lb_ip, $mgt_host, $wrk_host, $owner){
	host { 'Add management host name':
		name => "${mgt_host}",
		ensure => 'present',
		target => '/etc/hosts',
		comment => '<load balancer IP> <Manager Hostname>',
		ip => "${lb_ip}",
	}

	host { 'Add worker host name':
		name => "${wrk_host}",
		ensure => 'present',
		target => '/etc/hosts',
		comment => '<load balancer IP> <Worker Hostname>',
		ip => "${lb_ip}",
	}
}
	
