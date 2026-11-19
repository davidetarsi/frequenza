import pathlib
import unittest
import xml.etree.ElementTree as ET

ANDROID = '{http://schemas.android.com/apk/res/android}'
ROOT = pathlib.Path(__file__).resolve().parent.parent


class BackupTest(unittest.TestCase):
    """Favourites, saved songs and the diary come back on a new phone."""

    def test_the_app_says_it_is_backed_up(self):
        manifest = ET.parse(ROOT / 'android/app/src/main/AndroidManifest.xml')
        application = manifest.getroot().find('application')
        self.assertEqual(application.get(ANDROID + 'allowBackup'), 'true')

    def test_no_flavour_turns_the_backup_off(self):
        for manifest in (ROOT / 'android/app/src').glob('*/AndroidManifest.xml'):
            application = ET.parse(manifest).getroot().find('application')
            if application is not None:
                self.assertNotEqual(
                    application.get(ANDROID + 'allowBackup'), 'false', manifest
                )

    def test_legacy_cloud_and_device_transfer_back_up_only_user_records(self):
        application = ET.parse(
            ROOT / 'android/app/src/main/AndroidManifest.xml'
        ).getroot().find('application')

        def resource(attribute):
            reference = application.get(ANDROID + attribute)
            self.assertIsNotNone(reference)
            self.assertTrue(reference.startswith('@xml/'))
            return ET.parse(
                ROOT / 'android/app/src/main/res/xml' /
                (reference.removeprefix('@xml/') + '.xml')
            ).getroot()

        legacy = resource('fullBackupContent')
        extraction = resource('dataExtractionRules')
        modes = [legacy, extraction.find('cloud-backup'),
                 extraction.find('device-transfer')]
        user_files = {
            ('sharedpref', 'FlutterSharedPreferences.xml'),
            ('root', 'app_flutter/frequenza.sqlite'),
            ('root', 'app_flutter/frequenza.sqlite-wal'),
            ('root', 'app_flutter/frequenza.sqlite-journal'),
        }
        other_files = {
            ('sharedpref', 'future_sdk.xml'),
            ('root', 'app_flutter/frequenza.sqlite-shm'),
            ('root', 'app_flutter/session.log'),
            ('file', 'notification.png'),
            ('root', 'cache/audio.tmp'),
            ('external', 'download.tmp'),
        }
        for rules in modes:
            self.assertIsNotNone(rules)
            with self.subTest(mode=rules.tag):
                includes = [(entry.get('domain'), entry.get('path'))
                            for entry in rules.findall('include')]
                self.assertTrue(includes, 'Without includes Android backs up all files')

                def selected(domain, path):
                    return any(d == domain and (p == '.' or path == p or
                               path.startswith(p.rstrip('/') + '/'))
                               for d, p in includes)

                selected_files = {entry for entry in user_files | other_files
                                  if selected(*entry)}
                self.assertEqual(selected_files, user_files)


if __name__ == '__main__':
    unittest.main()
