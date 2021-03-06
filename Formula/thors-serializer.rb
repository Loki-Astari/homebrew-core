class ThorsSerializer < Formula
  desc "Declarative serialization library (JSON/YAML) for C++"
  homepage "https://github.com/Loki-Astari/ThorsSerializer"
  url "https://github.com/Loki-Astari/ThorsSerializer.git",
      tag:      "2.2.0",
      revision: "e51bb10e1f95a3d52391358c941a5e8dd92c1e4e"
  license "MIT"

  bottle do
    sha256 cellar: :any, arm64_big_sur: "7f6c671e7842eea5f5e6ab76a8e961805fb9f09f16f381101e1037ae2270b220"
    sha256 cellar: :any, big_sur:       "febdec67998826f6c02d103d7fc1392791f6674fb33c86dd727278b8b58583d0"
    sha256 cellar: :any, catalina:      "9bbd671562f15494d9bb012ed94d952c101d6864fb8320951fdcab8ea3810a68"
    sha256 cellar: :any, mojave:        "52f4348cba84e1b0f2b6f400c9519e094146715c592baf6501eb8772c55c7611"
  end

  depends_on "boost" => :build
  depends_on "libyaml"

  def install
    ENV["COV"] = "gcov"

    system "./configure", "--disable-vera",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include "ThorSerialize/JsonThor.h"
      #include "ThorSerialize/SerUtil.h"
      #include <sstream>
      #include <iostream>
      #include <string>

      struct HomeBrewBlock
      {
          std::string             key;
          int                     code;
      };
      ThorsAnvil_MakeTrait(HomeBrewBlock, key, code);

      int main()
      {
          using ThorsAnvil::Serialize::jsonImporter;
          using ThorsAnvil::Serialize::jsonExporter;

          std::stringstream   inputData(R"({"key":"XYZ","code":37373})");

          HomeBrewBlock    object;
          inputData >> jsonImporter(object);

          if (object.key != "XYZ" || object.code != 37373) {
              std::cerr << "Fail";
              return 1;
          }
          std::cerr << "OK";
          return 0;
      }
    EOS
    system ENV.cxx, "-std=c++17", "test.cpp", "-o", "test",
           "-I#{Formula["boost"].opt_include}",
           "-I#{include}", "-L#{lib}", "-lThorSerialize17", "-lThorsLogging17"
    system "./test"
  end
end
