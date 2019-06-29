import { Elm } from "./Main.elm";

// const settings = JSON.parse(localStorage.getItem("settings")) || {
//   darkMode: false,
//   language: "en"
// };

const app = Elm.Main.init({
  node: document.getElementById("app")
  //   flags: {
  //     settings
  //   }
});

// ports.settings.subscribe(function(settings) {
//   toggleDarkMode(settings.darkMode);
//   localStorage.setItem("settings", JSON.stringify(settings));
// });
