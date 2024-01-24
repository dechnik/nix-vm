# These values depend on your circumstances
{
  # Set this to match your users uid (run `id`)
  # Makes the files in this directory editable within the VM without sudo
  users.users.me.uid = 1000;

  # Set this to a portion of your host machine's resources
  virtualisation.vmVariant.virtualisation = {
    # 4 cores
    cores = 4;
    # 16GB RAM
    memorySize = 4 * 1024;
  };

  # Set this to your timezone (run `tzselect`)
  time.timeZone = "Europe/Warsaw";
}
