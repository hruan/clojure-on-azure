(defproject clojure-on-azure "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :dependencies [[org.clojure/clojure "1.6.0"]
                 [compojure "1.1.6"]
                 [hiccup "1.0.5"]
                 [ring-server "0.3.1"]]
  :local-repo #=(eval (str (System/getenv "HOME") "/.m2-repository"))
  :checksum :fail
  :plugins [[lein-ring "0.8.12"]]
  :ring {:handler clojure-on-azure.handler/app
         :init clojure-on-azure.handler/init
         :destroy clojure-on-azure.handler/destroy}
  :profiles
  {:uberjar {:aot :all}
   :production
   {:ring
    {:open-browser? false, :stacktraces? false, :auto-reload? false}}
   :dev
   {:dependencies [[ring-mock "0.1.5"] [ring/ring-devel "1.3.1"]]}})
