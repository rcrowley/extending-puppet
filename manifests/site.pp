github { "/root/.ssh/github-1":
	ensure   => present,
	token    => "0123456789abcdef0123456789abcdef",
	username => "rcrowley",
}

package { "django":
	ensure   => "1.3",
	provider => pip,
}

file { "/root/.ssh/github-2":
	content => github(
		"$clientcert",
		"rcrowley",
		"0123456789abcdef0123456789abcdef"
	),
	ensure => file,
	group => "root",
	mode => 0600,
	owner => "root",
}
