# number of worker nodes
NUM_WORKERS = 2
# number of extra disks per worker
NUM_DISKS = 1
# size of each disk in gigabytes
DISK_GBS = 16

MASTER_IP = "100.99.9.100"
WORKER_IP_BASE = "100.99.9.2" # 200, 201, ...
TOKEN = "yi6muo.4ytkfl3l6vl8zfpk"

Vagrant.configure("2") do |config|
  config.vm.box = "rockylinux/8"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider :libvirt do |libvirt|
    libvirt.cpu_mode = 'host-passthrough'
    libvirt.graphics_type = 'none'
    libvirt.memory = 2048
    libvirt.cpus = 2
    libvirt.qemu_use_session = false
    libvirt.machine_virtual_size = 16
  end

  config.vm.provision "shell", inline: <<-SHELL
      sudo dnf install -y cloud-utils-growpart
      sudo growpart /dev/vda 1
      sudo xfs_growfs /dev/vda1
    SHELL

  config.vm.provision "shell", path: "common.sh"
  config.vm.provision "shell", path: "local-storage/create-volumes.sh"

  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.network :private_network, ip: MASTER_IP
    master.vm.provision "shell", path: "master.sh",
      env: { "MASTER_IP" => MASTER_IP, "TOKEN" => TOKEN }

    master.vm.provision :file do |file|
      file.source = "local-storage/storageclass.yaml"
      file.destination = "/tmp/local-storage-storageclass.yaml"
    end
    master.vm.provision :file do |file|
      file.source = "local-storage/provisioner.yaml"
      file.destination = "/tmp/local-storage-provisioner.yaml"
    end
    master.vm.provision "shell", path: "local-storage/install.sh"
  end

  (0..NUM_WORKERS-1).each do |i|
    config.vm.define "worker#{i}" do |worker|
      worker.vm.hostname = "worker#{i}"
      worker.vm.network :private_network, ip: "#{WORKER_IP_BASE}" + i.to_s.rjust(2, '0')
      (1..NUM_DISKS).each do |j|
        worker.vm.provider :libvirt do |libvirt|
          libvirt.storage :file, :size => "#{DISK_GBS}G"
        end
      end
      worker.vm.provision "shell", path: "worker.sh",
        env: { "MASTER_IP" => MASTER_IP, "TOKEN" => TOKEN }
    end
  end
end
