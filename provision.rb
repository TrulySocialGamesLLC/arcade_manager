require 'nissh'

hosts = %w(tournaments.production.server-planet-gold-rush.com us1.central-db.production.server-planet-gold-rush.com us2.central-db.production.server-planet-gold-rush.com pmm.production.server-planet-gold-rush.com login1.production.server-planet-gold-rush.com  central-dbs.production.server-planet-gold-rush.com us1.app1.production.server-planet-gold-rush.com us1.app2.production.server-planet-gold-rush.com us1.app3.production.server-planet-gold-rush.com us1.app4.production.server-planet-gold-rush.com us2.app1.production.server-planet-gold-rush.com us2.app2.production.server-planet-gold-rush.com us2.app3.production.server-planet-gold-rush.com us2.app4.production.server-planet-gold-rush.com)
#hosts = %w(tournaments.loadtest.server-planet-gold-rush.com us1.central-db.loadtest.server-planet-gold-rush.com us2.central-db.loadtest.server-planet-gold-rush.com pmm.loadtest.server-planet-gold-rush.com login.loadtest.server-planet-gold-rush.com  central-dbs.loadtest.server-planet-gold-rush.com us1.app1.loadtest.server-planet-gold-rush.com us1.app2.loadtest.server-planet-gold-rush.com us1.app3.loadtest.server-planet-gold-rush.com us1.app4.loadtest.server-planet-gold-rush.com us2.app1.loadtest.server-planet-gold-rush.com us2.app2.loadtest.server-planet-gold-rush.com us2.app3.loadtest.server-planet-gold-rush.com us2.app4.loadtest.server-planet-gold-rush.com)
#hosts = %w(login.uat.server-planet-gold-rush.com us1.uat.server-planet-gold-rush.com us2.uat.server-planet-gold-rush.com)
hosts = %w(login.testing.server-planet-gold-rush.com us1.testing.server-planet-gold-rush.com us2.testing.server-planet-gold-rush.com)

token = 'SWMTKN-1-1yuvf206p0ye34nxr2ptv5r0pun5ie5398eejb6kz03hth8bvo-9d270uew7gkwomtpwcctnpgg8'
ip = '192.168.0.19:2377'

#hosts = %w(manager.loadtest.server-planet-gold-rush.com)

hosts.each do |host|
  begin
    session = Nissh::Session.new(host, 'ubuntu', keys: [ '/Users/atanych/Applications/golden_rush_cred/pgr-staging.pem' ])
    # session = Nissh::Session.new(host, 'ubuntu', keys: [ "~/Desktop/pgr-loadtest.pem" ])
    # session = Nissh::Session.new(host, 'ubuntu', keys: [ "~/Desktop/pgr-loadtest.pem" ])

    puts( "[#{host}]: " + session.execute!( "sudo hostnamectl set-hostname #{host}" ).stdout )
    puts( "[#{host}]: " + session.execute!( "hostname" ).stdout )

    puts( "[#{host}]: " + session.execute!( "sudo apt remove docker.io" ).stdout )
    puts( "[#{host}]: " + session.execute!( "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -" ).stdout )
    puts( "[#{host}]: " + session.execute!( 'sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"' ).stdout )
    puts( "[#{host}]: " + session.execute!( 'sudo apt update' ).stdout )
    puts( "[#{host}]: " + session.execute!( 'sudo apt install -y docker-ce' ).stdout )

    puts( "[#{host}]: " + session.execute!( 'sudo bash -c \' echo "[Link]" > /etc/systemd/network/99-default.link\'' ).stdout )
    puts( "[#{host}]: " + session.execute!( 'sudo bash -c \' echo "NamePolicy=kernel database onboard slot path" >> /etc/systemd/network/99-default.link\'' ).stdout )
    puts( "[#{host}]: " + session.execute!( 'sudo bash -c \' echo "MACAddressPolicy=none" >> /etc/systemd/network/99-default.link\'' ).stdout )

    puts( "[#{host}]: " + session.execute!( 'cat /etc/systemd/network/99-default.link' ).stdout )

    puts( "[#{host}]: " + session.execute!( 'docker swarm join --listen-addr `ifconfig | grep -oE "inet addr:(192.168.[0-9]+.[0-9]+)" | grep -oE "(192.168.[0-9]+.[0-9]+)"` --advertise-addr `ifconfig | grep -oE "inet addr:(192.168.[0-9]+.[0-9]+)" | grep -oE "(192.168.[0-9]+.[0-9]+)"` --token ' + "#{token} #{ip}", sudo: true ).stdout )

    puts( "[#{host}]: " + session.execute!( 'sysctl -w net.ipv4.tcp_keepalive_time=600', sudo: true ).stdout )
    puts( "[#{host}]: " + session.execute!( 'sysctl -w net.ipv4.tcp_keepalive_intvl=60', sudo: true ).stdout )
    puts( "[#{host}]: " + session.execute!( 'sysctl -w net.ipv4.tcp_keepalive_probes=20', sudo: true ).stdout )

    puts( "[#{host}]: " + session.execute!( 'touch /etc/sysctl.d/20-ipvs-tcp-keepalive.conf', sudo: true ).stdout )
    puts( "[#{host}]: " + session.execute!( 'chmod 777 /etc/sysctl.d/20-ipvs-tcp-keepalive.conf', sudo: true ).stdout )
    puts( "[#{host}]: " + session.execute!( 'echo "net.ipv4.tcp_keepalive_time = 600" > /etc/sysctl.d/20-ipvs-tcp-keepalive.conf' ).stdout )
    puts( "[#{host}]: " + session.execute!( 'echo "net.ipv4.tcp_keepalive_intvl = 60" >> /etc/sysctl.d/20-ipvs-tcp-keepalive.conf' ).stdout )
    puts( "[#{host}]: " + session.execute!( 'echo "net.ipv4.tcp_keepalive_probes = 20" >> /etc/sysctl.d/20-ipvs-tcp-keepalive.conf' ).stdout )
    puts( "[#{host}]: " + session.execute!( 'chmod 644 /etc/sysctl.d/20-ipvs-tcp-keepalive.conf', sudo: true ).stdout )

    puts( "[#{host}]: " + session.execute!( 'sudo reboot' ).stdout )
  rescue => ex
    puts ex
  end
end
