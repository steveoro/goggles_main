function importAll (r) {
  r.keys().forEach(r)
}

// [Steve A.] Reach out directly to 'app/components' for each component JS assets, if any:
importAll(require.context('../../components', true, /[_/]component\.js$/))
