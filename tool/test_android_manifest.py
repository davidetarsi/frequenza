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


if __name__ == '__main__':
    unittest.main()
