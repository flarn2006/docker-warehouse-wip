set -ev

cd /root/ssl
openssl genrsa -out server.key 1024

forge() {
	cat > temp.cnf <<-EOF
		[ req ]
		distinguished_name = dn
		req_extensions = req_ext
		prompt = no

		[ dn ]
		C = CH
		O = Unintendo of America, Inc.
		CN = $1

		[ req_ext ]
		subjectAltName = DNS:$1
	EOF
	openssl req -new -config temp.cnf -key server.key -out temp.csr
	filename=${1/\*/_}
	openssl x509 -req -in temp.csr -CA CA.crt -CAkey CA.key -CAcreateserial -days 365 -sha1 -out $filename.crt
	cat $filename.crt CA.crt > $filename.chain.crt
}

forge nas.nintendowifi.net

(
	cd /root/dwc
	python2 master_server.py
) &

/usr/local/nginx/sbin/nginx
