require 'spec_helper_acceptance'

describe 'createrepo define:', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'basic usage:' do
    it 'should work with no errors' do
      pp = <<-EOS
        file { '/var/yumrepos': ensure => directory, }
        file { '/var/cache/yumrepos': ensure => directory, }
        createrepo { 'test-repo': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file('/var/yumrepos/test-repo/repodata') do
      it { should be_directory }
    end

    describe cron do
      if fact('osfamily') != 'RedHat'
        it { should have_entry('*/1 * * * * /usr/bin/createrepo --cachedir /var/cache/yumrepos/test-repo --update /var/yumrepos/test-repo').with_user('root') }
      else
        it { should have_entry('*/1 * * * * /usr/bin/createrepo --cachedir /var/cache/yumrepos/test-repo --changelog-limit 5 --update /var/yumrepos/test-repo').with_user('root') }
      end
    end

    describe file('/usr/local/bin/createrepo-update-test-repo') do
      it { should be_file }
      it { should be_mode '755' }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      if fact('osfamily') != 'RedHat'
        it { should contain '/usr/bin/createrepo --cachedir /var/cache/yumrepos/test-repo --update /var/yumrepos/test-repo' }
      else
        it { should contain '/usr/bin/createrepo --cachedir /var/cache/yumrepos/test-repo --changelog-limit 5 --update /var/yumrepos/test-repo' }
      end
    end
  end
end