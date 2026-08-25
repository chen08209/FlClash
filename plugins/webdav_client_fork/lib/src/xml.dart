import 'package:xml/xml.dart';

import 'file.dart';
import 'utils.dart';

const fileXmlStr = '''<d:propfind xmlns:d='DAV:'>
			<d:prop>
				<d:displayname/>
				<d:resourcetype/>
				<d:getcontentlength/>
				<d:getcontenttype/>
				<d:getetag/>
				<d:getlastmodified/>
			</d:prop>
		</d:propfind>''';

// const quotaXmlStr = '''<d:propfind xmlns:d="DAV:">
//            <d:prop>
//              <d:quota-available-bytes/>
//              <d:quota-used-bytes/>
//            </d:prop>
//          </d:propfind>''';

class WebdavXml {
  static List<XmlElement> findAllElements(XmlDocument document, String tag) =>
      document.findAllElements(tag, namespace: '*').toList();

  static List<XmlElement> findElements(XmlElement element, String tag) =>
      element.findElements(tag, namespace: '*').toList();

  static List<File> toFiles(String path, String xmlStr, {skipSelf = true}) {
    var files = <File>[];
    var xmlDocument = XmlDocument.parse(xmlStr);
    List<XmlElement> list = findAllElements(xmlDocument, 'response');
    // response
    list.forEach((element) {
      // name
      final hrefElements = findElements(element, 'href');
      String href = hrefElements.isNotEmpty ? hrefElements.single.text : '';

      // propstats
      var props = findElements(element, 'propstat');
      // propstat
      for (var propstat in props) {
        // ignore != 200
        if (findElements(propstat, 'status').single.text.contains('200')) {
          // prop
          for (var prop in findElements(propstat, 'prop')) {
            final resourceTypeElements = findElements(prop, 'resourcetype');
            // isDir
            bool isDir = resourceTypeElements.isNotEmpty
                ? findElements(resourceTypeElements.single, 'collection')
                    .isNotEmpty
                : false;

            // skip self
            if (skipSelf) {
              skipSelf = false;
              if (isDir) {
                break;
              }
              throw newXmlError('xml parse error(405)');
            }

            // mimeType
            final mimeTypeElements = findElements(prop, 'getcontenttype');
            String mimeType =
                mimeTypeElements.isNotEmpty ? mimeTypeElements.single.text : '';

            // size
            int size = 0;
            if (!isDir) {
              final sizeElements = findElements(prop, 'getcontentlength');
              size = sizeElements.isNotEmpty
                  ? int.parse(sizeElements.single.text)
                  : 0;
            }

            // eTag
            final eTagElements = findElements(prop, 'getetag');
            String eTag =
                eTagElements.isNotEmpty ? eTagElements.single.text : '';

            // create time
            final cTimeElements = findElements(prop, 'creationdate');
            DateTime? cTime = cTimeElements.isNotEmpty
                ? DateTime.parse(cTimeElements.single.text).toLocal()
                : null;

            // modified time
            final mTimeElements = findElements(prop, 'getlastmodified');
            DateTime? mTime = mTimeElements.isNotEmpty
                ? str2LocalTime(mTimeElements.single.text)
                : null;

            //
            var str = Uri.decodeFull(href);
            var name = path2Name(str);
            var filePath = path + name + (isDir ? '/' : '');

            files.add(File(
              path: filePath,
              isDir: isDir,
              name: name,
              mimeType: mimeType,
              size: size,
              eTag: eTag,
              cTime: cTime,
              mTime: mTime,
            ));
            break;
          }
        }
      }
    });
    return files;
  }
}
