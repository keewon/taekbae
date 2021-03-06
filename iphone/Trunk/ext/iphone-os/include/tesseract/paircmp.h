/**********************************************************************
 * File:        paircmp.h  (Formerly paircmp.h)
 * Description: Code to compare two blobs using the adaptive matcher
 * Author:		Ray Smith
 * Created:		Wed Apr 21 09:31:02 BST 1993
 *
 * (C) Copyright 1993, Hewlett-Packard Ltd.
 ** Licensed under the Apache License, Version 2.0 (the "License");
 ** you may not use this file except in compliance with the License.
 ** You may obtain a copy of the License at
 ** http://www.apache.org/licenses/LICENSE-2.0
 ** Unless required by applicable law or agreed to in writing, software
 ** distributed under the License is distributed on an "AS IS" BASIS,
 ** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 ** See the License for the specific language governing permissions and
 ** limitations under the License.
 *
 **********************************************************************/

#ifndef           PAIRCMP_H
#define           PAIRCMP_H

#include          "ocrblock.h"
#include          "varable.h"
#include          "notdll.h"

BOOL8 compare_blob_pairs(             //blob processor
                         BLOCK *,
                         ROW *row,    //row it came from
                         WERD *,
                         PBLOB *blob  //blob to compare
                        );
float compare_blobs(               //match 2 blobs
                    PBLOB *blob1,  //first blob
                    ROW *row1,     //row it came from
                    PBLOB *blob2,  //other blob
                    ROW *row2);
float compare_bln_blobs(               //match 2 blobs
                        PBLOB *blob1,  //first blob
                        DENORM *denorm1,
                        PBLOB *blob2,  //other blob
                        DENORM *denorm2);
#endif
