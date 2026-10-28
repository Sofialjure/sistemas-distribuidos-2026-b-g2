upstream professional_management { server pm-blue:8080; keepalive 16; }
map $host $served_by { default "blue 2848b52"; }
