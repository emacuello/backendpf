resource "null_resource" "copy_file" {
  provisioner "local-exec" {
    command = "scp -i ${var.sv_name}.key -o StrictHostKeyChecking=no ./env.prod ubuntu@${aws_instance.youdrive-api.public_ip}:/home/ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/ubuntu/env.prod /home/ubuntu/backendpf/.env.development",
      "sudo chown root:root /desired/path/on/server/file",
      "sudo chmod 644 /desired/path/on/server/file"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.sv_name}.key")
      host        = aws_instance.youdrive-api.public_ip
    }
  }

  depends_on = [aws_instance.youdrive-api]
}
