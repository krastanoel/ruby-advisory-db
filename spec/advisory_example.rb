load File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'yaml'

shared_examples_for 'Advisory' do |path|
  advisory = YAML.safe_load_file(path, permitted_classes: [Date])

  describe path do
    let(:filename) { File.basename(path) }

    let(:filename_cve) do
      if filename.start_with?('CVE-')
        filename.gsub('CVE-','')
      end
    end

    let(:filename_osvdb) do
      if filename.start_with?('OSVDB-')
        filename.gsub('OSVDB-','')
      end
    end
    
    let(:filename_ghsa) do
      if filename.start_with?('GHSA-')
        filename.gsub('GHSA-','')
      end
    end

    it "should be correctly named CVE-XXX or OSVDB-XXX or GHSA-XXX" do
      expect(filename).
        to match(/^(CVE-\d{4}-(0\d{3}|[1-9]\d{3,})|OSVDB-\d+|GHSA(-[a-z0-9]{4}){3})\.yml$/)
    end

    it "should have CVE or OSVDB or GHSA" do
      expect(advisory['cve'] || advisory['osvdb'] || advisory['ghsa']).not_to be_nil
    end

    describe "library" do
      subject { advisory['library'] }

      it "may be nil or a String" do
        expect(subject).to be_kind_of(String).or(be_nil)
      end
    end

    describe "framework" do
      subject { advisory['framework'] }

      it "may be nil or a String" do
        expect(subject).to be_kind_of(String).or(be_nil)
      end
    end

    describe "platform" do
      subject { advisory['platform'] }

      it "may be nil or a String" do
        expect(subject).to be_kind_of(String).or(be_nil)
      end
    end

    describe "cve" do
      subject { advisory['cve'] }

      it "may be nil or a String" do
        expect(subject).to be_kind_of(String).or(be_nil)
      end
      it "should be id in filename if filename is CVE-XXX" do
        if filename_cve
          is_expected.to eq(filename_cve.chomp('.yml'))
        end
      end
    end

    describe "osvdb" do
      subject { advisory['osvdb'] }

      it "may be nil or a Integer" do
        expect(subject).to be_kind_of(Integer).or(be_nil)
      end

       it "should be id in filename if filename is OSVDB-XXX" do
        if filename_osvdb
          is_expected.to eq(filename_osvdb.to_i)
        end
      end
    end
    
    describe "ghsa" do
      subject { advisory['ghsa'] }

      it "may be nil or a String" do
        expect(subject).to be_kind_of(String).or(be_nil)
      end
      it "should be id in filename if filename is GHSA-XXX" do
        if filename_ghsa
          is_expected.to eq(filename_ghsa.chomp('.yml'))
        end
      end
    end

    describe "url" do
      subject { advisory['url'] }

      it { is_expected.to be_kind_of(String) }
      it { is_expected.not_to be_empty }
    end

    describe "title" do
      subject { advisory['title'] }

      it { is_expected.to be_kind_of(String) }
      it { is_expected.not_to be_empty }

      it "must be one line" do
        is_expected.to_not include("\n")
      end
    end

    describe "date" do
      subject { advisory['date'] }

      it { is_expected.to be_kind_of(Date) }
    end

    describe "description" do
      subject { advisory['description'] }

      it { is_expected.to be_kind_of(String) }
      it { is_expected.not_to be_empty }
    end

    describe "cvss_v2" do
      subject { advisory['cvss_v2'] }

      it "may be nil or a Float" do
        expect(subject).to be_kind_of(Float).or(be_nil)
      end

      case advisory['cvss_v2']
      when Float
        context "when a Float" do
          it { expect((0.0)..(10.0)).to include(subject) }
        end
      end
    end

    describe "cvss_v3" do
      subject { advisory['cvss_v3'] }

      it "may be nil or a Float" do
        expect(subject).to be_kind_of(Float).or(be_nil)
      end

      case advisory['cvss_v3']
      when Float
        context "when a Float" do
          it { expect((0.0)..(10.0)).to include(subject) }
        end
      end

      if advisory['cvss_v2']
        it "should also provide a cvss_v2 score" do
          expect(advisory['cvss_v2']).to_not be_nil
        end
      end
    end

    describe "patched_versions" do
      subject { advisory['patched_versions'] }

      it "may be nil or an Array" do
        expect(subject).to be_kind_of(Array).or(be_nil)
      end

      describe "each patched version" do
        if advisory['patched_versions']
          advisory['patched_versions'].each do |version|
            describe version do
              subject { version.split(', ') }

              it "should contain valid RubyGem version requirements" do
                expect {
                Gem::Requirement.new(*subject)
                }.not_to raise_error
              end
            end
          end
        end
      end
    end

    describe "unaffected_versions" do
      subject { advisory['unaffected_versions'] }

      it "may be nil or an Array" do
        expect(subject).to be_kind_of(Array).or(be_nil)
      end

      case advisory['unaffected_versions']
      when Array
        advisory['unaffected_versions'].each do |version|
          describe version do
            subject { version.split(', ') }

            it "should contain valid RubyGem version requirements" do
              expect {
                Gem::Requirement.new(*subject)
              }.not_to raise_error
            end
          end
        end
      end
    end

    describe "related" do
      subject { advisory['related'] }

      it "may be nil or a Hash" do
        expect(subject).to be_kind_of(Hash).or(be_nil)
      end

      case advisory["related"]
      when Hash
        advisory["related"].each_pair do |name, values|
          describe name do
            it "should be either a cve, an osvdb, a ghsa, or a url" do
              expect(["cve", "osvdb", "ghsa", "url"]).to include(name)
            end

            it "should always contain an array" do
              expect(values).to be_kind_of(Array)
            end
          end
        end
      end
    end

    describe "notes" do
      subject { advisory['notes'] }

      it "may be nil or a String" do
        expect(subject).to be_kind_of(String).or(be_nil)
      end
    end

  end
end
