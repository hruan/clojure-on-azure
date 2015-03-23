(ns clojure-on-azure.views.layout
  (:require [hiccup.page :refer [html5 include-css]]))

(defn common [& body]
  (html5
    [:head
     [:title "Welcome to clojure-on-azure"]
     (include-css "/css/screen.css")]
    [:body body]))
