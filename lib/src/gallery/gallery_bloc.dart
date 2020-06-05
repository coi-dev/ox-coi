/*
 * OPEN-XCHANGE legal information
 *
 * All intellectual property rights in the Software are protected by
 * international copyright laws.
 *
 *
 * In some countries OX, OX Open-Xchange and open xchange
 * as well as the corresponding Logos OX Open-Xchange and OX are registered
 * trademarks of the OX Software GmbH group of companies.
 * The use of the Logos is not covered by the Mozilla Public License 2.0 (MPL 2.0).
 * Instead, you are allowed to use these Logos according to the terms and
 * conditions of the Creative Commons License, Version 2.5, Attribution,
 * Non-commercial, ShareAlike, and the interpretation of the term
 * Non-commercial applicable to the aforementioned license is published
 * on the web site https://www.open-xchange.com/terms-and-conditions/.
 *
 * Please make sure that third-party modules and libraries are used
 * according to their respective licenses.
 *
 * Any modifications to this package must retain all copyright notices
 * of the original copyright holder(s) for the original code used.
 *
 * After any such modifications, the original and derivative code shall remain
 * under the copyright of the copyright holder(s) and/or original author(s) as stated here:
 * https://www.open-xchange.com/legal/. The contributing author shall be
 * given Attribution for the derivative code and a license granting use.
 *
 * Copyright (C) 2016-2020 OX Software GmbH
 * Mail: info@open-xchange.com
 *
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the Mozilla Public License 2.0
 * for more details.
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/gallery/gallery_event_state.dart';
import 'package:video_player/video_player.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  VideoPlayerController _controller;

  @override
  GalleryState get initialState => GalleryInitial();

  @override
  Stream<GalleryState> mapEventToState(GalleryEvent event) async* {
    if (event is InitializeVideoPlayer) {
      yield* initializeVideoAsync(event.path);
    } else if (event is PlayVideoPlayer) {
      yield* playVideoAsync();
    } else if (event is PauseVideoPlayer) {
      yield* pauseVideoAsync();
    } else if (event is SeekVideoPlayer) {
      yield* seekVideoAsync(event.position, event.videoStopped);
    } else if (event is UpdateVideoPlayerPosition) {
      yield VideoPlayerStateSuccess(isPlaying: event.isPlaying, position: event.position);
    } else if (event is VideoPlayerStopped) {
      yield VideoPlayerStateSuccess(isPlaying: false, position: _videoPlayerPosition);
    }
  }

  Stream<GalleryState> initializeVideoAsync(String path) async* {
    _controller?.removeListener(_videoPlayerListener);
    yield VideoPlayerDisposed();
    await Future.delayed(Duration(milliseconds: 100));
    await _controller?.dispose();
    _controller = VideoPlayerController.network("file://${Uri.encodeFull(path)}");
    addVideoPlayerListener();
    await _controller.initialize();
    await Future.delayed(Duration(milliseconds: 100));
    yield VideoPlayerInitialized(videoPlayerController: _controller, duration: _videoPlayerDuration);
  }

  Stream<GalleryState> playVideoAsync() async* {
    if (_videoPlayerPosition == _videoPlayerDuration) {
      await _controller.seekTo(Duration(milliseconds: 0));
    }
    await _controller.play();
    yield VideoPlayerStateSuccess(isPlaying: true, position: _videoPlayerPosition);
  }

  Stream<GalleryState> pauseVideoAsync() async* {
    await _controller.pause();
    yield VideoPlayerStateSuccess(isPlaying: false, position: _videoPlayerPosition);
  }

  Stream<GalleryState> seekVideoAsync(double seekTo, bool videoStopped) async* {
    await _controller.seekTo(Duration(milliseconds: seekTo.toInt()));
    if (videoStopped) {
      await _controller.pause();
    }
    yield VideoPlayerStateSuccess(isPlaying: !videoStopped, position: _videoPlayerPosition);
  }

  void addVideoPlayerListener() => _controller?.addListener(_videoPlayerListener);

  _videoPlayerListener() {
    if (_videoPlayerPosition != null && _videoPlayerDuration != null) {
      if (_videoPlayerPosition < _videoPlayerDuration && _videoPlayerPosition > 0) {
        add(UpdateVideoPlayerPosition(isPlaying: _controller.value.isPlaying, position: _videoPlayerPosition));
      } else if (_videoPlayerPosition == _videoPlayerDuration) {
        add(VideoPlayerStopped());
      }
    }
  }

  int get _videoPlayerPosition => _controller?.value?.position?.inMilliseconds;

  int get _videoPlayerDuration => _controller?.value?.duration?.inMilliseconds;
}
