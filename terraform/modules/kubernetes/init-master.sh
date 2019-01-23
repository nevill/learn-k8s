mkdir -p /etc/kubernetes/pki/etcd/
cat << EOF > /etc/kubernetes/pki/etcd/ca.crt
${etcd_ca_crt}
EOF

cat << EOF > /etc/kubernetes/pki/etcd/ca.key
${etcd_ca_key}
EOF

cat << EOF > /etc/kubernetes/pki/sa.pub
${sa_public_key}
EOF

cat << EOF > /etc/kubernetes/pki/sa.key
${sa_private_key}
EOF

cat << EOF > /etc/kubernetes/pki/ca.crt
${k8s_ca_crt}
EOF

cat << EOF > /etc/kubernetes/pki/ca.key
${k8s_ca_key}
EOF

cd ~root
kubeadm init --config kubeadm-config.yml
