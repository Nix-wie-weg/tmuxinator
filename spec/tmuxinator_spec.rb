require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Tmuxinator::ConfigWriter do
  context "With no defined filename" do
    its(:file_path){ should be_nil }
    its(:project_name){ should be_nil }
    its(:project_root){ should be_nil }
    its(:rvm){ should be_nil }
    its(:tabs){ should be_nil }
    its(:config_path){ should be_nil }
    its(:pre){ should be_nil }
    its(:socket){ should be_nil }
  end

  context "While Defining the filename on init" do
    subject{ Tmuxinator::ConfigWriter.new(SAMPLE_CONFIG) }
    its(:file_path){ should eql SAMPLE_CONFIG }
    its(:file_name){ should eql "sample" }
  end

  context "After filename has been defined" do
    before do
      subject.file_path = SAMPLE_CONFIG
    end

    its(:file_path){ should eql SAMPLE_CONFIG }
    its(:file_name){ should eql File.basename(SAMPLE_CONFIG, '.yml')}
    its(:project_name){ should eql 'Tmuxinator' }
    its(:project_root){ should eql '~/code/rails_project' }
    its(:rvm){ should eql '1.9.2@rails_project' }
    its(:tabs){ should be_an Array  }
    its(:pre){ should eql 'rvm use 1.9.2@rails_project && sudo /etc/rc.d/mysqld start' }
    its(:socket){ should eql '-L foo' }

    let(:first_tab){ subject.tabs[0] }

    specify{ first_tab.should be_an OpenStruct }
    specify{ first_tab.name.should eql "editor" }
    specify{ first_tab.layout.should eql "main-vertical" }
    specify{ first_tab.panes.should be_an Array }
    specify{ first_tab.pre.should eql "rvm use 1.9.2@rails_project && echo 'I get run in each pane.  Before each pane command!'" }

    it "should prepend each pane with the rvm string" do
      first_tab.panes.map{|p| p.split(/ && /)[0] }.should eql ["rvm use 1.9.2@rails_project"] * 3
    end

    it "should append each pane with the command string" do
      first_tab.panes.map{|p| p.split(/ && /)[1] }.should eql ["vim", nil, "top"]
    end

    let(:second_tab){ subject.tabs[1] }
    specify{ second_tab.name.should eql "shell" }
    specify{ second_tab.command.should eql "rvm use 1.9.2@rails_project && git pull"}

    let(:third_tab){ subject.tabs[2] }
    specify{ third_tab.should be_an OpenStruct }
    specify{ third_tab.name.should eql "guard" }
    specify{ third_tab.layout.should eql "tiled" }
    specify{ third_tab.panes.should be_an Array }
    specify{ third_tab.pre.should eql "rvm use 1.9.2@rails_project && echo 'I get run in each pane.' && echo 'Before each pane command!'"}
  end

  context 'with erb-enabled config file' do
    before do
      subject.file_path = SAMPLE_ERB_CONFIG
    end
    its(:project_name){ should eql 'test3' }
    its(:project_root){ should eql '/tmp' }
    its(:tabs){ should be_an Array  }
    let(:first_tab){ subject.tabs[0] }
    specify{ first_tab.command.should eql 'echo Hello world' }
  end
end
