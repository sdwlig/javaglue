/* This source file is part of XBiG
 *     (XSLT Bindings Generator)
 * For the latest info, see http://sourceforge.net/projects/xbig/
 *
 * Copyright (c) 2005 netAllied GmbH, Tettnang
 * Also see acknowledgements in Readme.html
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free Software
 * Foundation; either version 2 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
 * Place - Suite 330, Boston, MA 02111-1307, USA, or go to
 * http://www.gnu.org/copyleft/lesser.txt.
 */

/**
 * This file defines types that are added to the Xbig inputs so that certain types are available for usage in interfaces.
 *
 */

#ifndef _Included_xbig_basedelete_h
#define _Included_xbig_basedelete_h

#include <jni.h>
#include <string>
#include <vector>
#include <map>

namespace base {
typedef std::vector<unsigned char> ByteVector;
typedef std::vector<std::string> StringVector;
typedef std::vector<ByteVector> VectorByteVector;
typedef std::map<std::string, ByteVector> MapStringByteVector;
typedef std::map<long, ByteVector> MapLongByteVector;
typedef std::map<std::string, std::string> MapStringString;
}
class Delete {
  public:
    static void byteVector(base::ByteVector* bv);
    static void stringVector(base::StringVector* sv);
    static void vectorByteVector(base::VectorByteVector* vbv);
    static void mapStringByteVector(base::MapStringByteVector* msbv);
    static void mapLongByteVector(base::MapLongByteVector* mlbv);
    static void mapStringString(base::MapStringString* mss);
};

// See jni_base.h for JNIEXPORTs
#endif // _Included_xbig_basedelete_h
