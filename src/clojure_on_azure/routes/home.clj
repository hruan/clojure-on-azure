(ns clojure-on-azure.routes.home
  (:require [compojure.core :refer :all]
            [clojure-on-azure.views.layout :as layout]))

(defn home []
  (layout/common [:h1 "Hello World!"]))

(defroutes home-routes
  (GET "/" [] (home)))
