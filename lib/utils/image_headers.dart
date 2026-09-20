/// En-têtes envoyés lors du téléchargement des images d'articles (souvent
/// hébergées sur d'autres sites via les flux RSS). Certains sites bloquent
/// les téléchargements qui n'ont pas d'en-tête "navigateur" standard.
const Map<String, String> kImageHeaders = {
  'User-Agent':
      'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Mobile Safari/537.36',
  'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
};
