Shindo.tests('Fog::Compute[:ninefold] | server requests', ['ninefold']) do

  tests('success') do


    tests("#deploy_virtual_machine()").formats(Ninefold::Compute::Formats::VirtualMachines::VIRTUAL_MACHINE) do
      pending if Fog.mocking?
      networks = Fog::Compute[:ninefold].list_networks

      unless networks[0]
        raise "No networks, ensure a network has been created by deploying a VM from the web UI and verify list_networks test"
      end

      newvm = Fog::Compute[:ninefold].deploy_virtual_machine(:serviceofferingid => Ninefold::Compute::TestSupport::SERVICE_OFFERING,
                                                        :templateid => Ninefold::Compute::TestSupport::TEMPLATE_ID,
                                                        :zoneid => Ninefold::Compute::TestSupport::ZONE_ID,
                                                        :networkids => networks[0]['id'])
      # wait for deployment, stash the job id.
      @newvmid = newvm['id']
      result = Ninefold::Compute::TestSupport.wait_for_job(newvm['jobid'])['jobresult']['virtualmachine']
      Ninefold::Compute::Formats::VirtualMachines::fill_virtual_machine_data(result)
    end

    tests("#list_virtual_machines()").formats(Ninefold::Compute::Formats::VirtualMachines::VIRTUAL_MACHINES) do
      pending if Fog.mocking?
      vms = Fog::Compute[:ninefold].list_virtual_machines
      # This is a hack to work around the changing format - these fields may or may not exist.
      Ninefold::Compute::Formats::VirtualMachines::fill_virtual_machine_data(vms)
    end

    tests("#reboot_virtual_machine()").formats(Ninefold::Compute::Formats::VirtualMachines::VIRTUAL_MACHINE) do
      pending if Fog.mocking?
      job = Fog::Compute[:ninefold].reboot_virtual_machine(:id => @newvmid)
      result = Ninefold::Compute::TestSupport.wait_for_job(job)['jobresult']['virtualmachine']
      Ninefold::Compute::Formats::VirtualMachines::fill_virtual_machine_data(result)
    end

    tests("#stop_virtual_machine()").formats(Ninefold::Compute::Formats::VirtualMachines::VIRTUAL_MACHINE) do
      pending if Fog.mocking?
      job = Fog::Compute[:ninefold].stop_virtual_machine(:id => @newvmid)
      result = Ninefold::Compute::TestSupport.wait_for_job(job)['jobresult']['virtualmachine']
      Ninefold::Compute::Formats::VirtualMachines::fill_virtual_machine_data(result)
    end


    tests("#change_service_for_virtual_machine()").formats(Ninefold::Compute::Formats::VirtualMachines::VIRTUAL_MACHINE) do
      pending if Fog.mocking?
      vms = Fog::Compute[:ninefold].change_service_for_virtual_machine(:id => @newvmid,
                                                                  :serviceofferingid => Ninefold::Compute::TestSupport::ALT_SERVICE_OFFERING)
      Ninefold::Compute::Formats::VirtualMachines::fill_virtual_machine_data(vms)
    end

    tests("#start_virtual_machine()").formats(Ninefold::Compute::Formats::VirtualMachines::VIRTUAL_MACHINE) do
      pending if Fog.mocking?
      job = Fog::Compute[:ninefold].start_virtual_machine(:id => @newvmid)
      result = Ninefold::Compute::TestSupport.wait_for_job(job)['jobresult']['virtualmachine']
      Ninefold::Compute::Formats::VirtualMachines::fill_virtual_machine_data(result)
    end

    tests("#destroy_virtual_machine()").formats(Ninefold::Compute::Formats::VirtualMachines::VIRTUAL_MACHINE) do
      pending if Fog.mocking?
      job = Fog::Compute[:ninefold].destroy_virtual_machine(:id => @newvmid)
      result = Ninefold::Compute::TestSupport.wait_for_job(job)['jobresult']['virtualmachine']
      Ninefold::Compute::Formats::VirtualMachines::fill_virtual_machine_data(result)
    end

  end

  tests('failure') do

    tests("#deploy_virtual_machine()").raises(Excon::Errors::HTTPStatusError) do
      pending if Fog.mocking?
      Fog::Compute[:ninefold].deploy_virtual_machine
    end

  end

end
