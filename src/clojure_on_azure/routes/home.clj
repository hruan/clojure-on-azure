(ns clojure-on-azure.routes.home
  (:require [compojure.core :refer :all]
            [clojure-on-azure.views.layout :as layout]))

(defn home []
  (layout/common [:h1 "Hello Azure Websites!"]))

(defroutes home-routes
  (GET "/" [] (home)))
